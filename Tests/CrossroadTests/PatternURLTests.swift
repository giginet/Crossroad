import XCTest
@testable import Crossroad

final class PatternURLTests: XCTestCase {
    func testPatternURL() {
        let checkSameComponents: ((_ string: String) -> Void) = { string in
            let patternURL = buildPatternURL(patternURLString: string)!
            let url = URL(string: string)!
            XCTAssertEqual(patternURL.host, url.host)
            XCTAssertEqual(patternURL.pathComponents, url.pathComponents)
        }

        checkSameComponents("foobar://static")
        checkSameComponents("foobar://foo/bar")
        checkSameComponents("foobar://spam/ham")
        checkSameComponents("foobar://foo/:keyword")
    }
    
    func testBuildRelativePatternURL() throws {
        let subjects: [(String, String, [String], UInt)] = [
            ("/foo", "foo", ["/"], #line),
            ("/foo/bar", "foo", ["/", "bar"], #line),
            ("/", "", ["/"], #line),
        ]
        
        for (pattern, host, pathComponents, line) in subjects {
            let patternURL = try XCTUnwrap(buildPatternURL(patternURLString: pattern), line: #line)
            XCTAssertTrue(patternURL is RelativePatternURL, line: line)
            XCTAssertEqual(patternURL.host, host, line: line)
            XCTAssertEqual(patternURL.pathComponents, pathComponents, line: line)
        }
    }
    
    func testBuildAbsolutePatternURL() throws {
        let subjects: [(String, String?, String, [String], UInt)] = [
            ("foobar://foo/bar", "foobar", "foo", ["/", "bar"], #line),
            ("pokedex://pokemons", "pokedex", "pokemons", [], #line),
            ("pokedex://pokemons/:pokemon_id", "pokedex", "pokemons", ["/", ":pokemon_id"], #line),
        ]
        
        for (pattern, scheme, host, pathComponents, line) in subjects {
            let patternURL = try XCTUnwrap(buildPatternURL(patternURLString: pattern), line: #line)
            let absolutePatternURL = try XCTUnwrap(patternURL as? AbsolutePatternURL, line: line)
            XCTAssertEqual(absolutePatternURL.prefix, .scheme(scheme!), line: #line)
            XCTAssertEqual(patternURL.host, host, line: line)
            XCTAssertEqual(patternURL.pathComponents, pathComponents, line: line)
        }
    }

    func testCapitalCase() throws {
        let subject = buildPatternURL(patternURLString: "FOOBAR://FOO/BAR")!
        let patternURL: AbsolutePatternURL = try XCTUnwrap(subject as? AbsolutePatternURL)
        XCTAssertEqual(patternURL.prefix, .scheme("FOOBAR"))
        XCTAssertEqual(patternURL.host, "FOO")
        XCTAssertEqual(patternURL.pathComponents, ["/", "BAR"])
    }

    func testParseWithKeyword() throws {
        let url0 = buildPatternURL(patternURLString: "foobar://search/:keyword")
        let patternURL0: AbsolutePatternURL = try XCTUnwrap(url0 as? AbsolutePatternURL)
        XCTAssertEqual(patternURL0.prefix, .scheme("foobar"))
        XCTAssertEqual(patternURL0.host, "search")
        XCTAssertEqual(patternURL0.pathComponents, ["/", ":keyword"])

        let url1 = buildPatternURL(patternURLString: "foobar://:keyword")
        let patternURL1: AbsolutePatternURL = try XCTUnwrap(url1 as? AbsolutePatternURL)
        XCTAssertEqual(patternURL1.prefix, .scheme("foobar"))
        XCTAssertEqual(patternURL1.host, ":keyword")
        XCTAssertEqual(patternURL1.pathComponents, [])
    }

    func testParseInvalidPattern() {
        func assertShouldFailed(_ string: String, line: Int) {
            let url0 = buildPatternURL(patternURLString: string)
            XCTAssertNil(url0)
        }

        assertShouldFailed("without_schema", line: #line)
        assertShouldFailed("invalid_schema://////aaaaaaa", line: #line)
    }

    func testHasPrefix() {
        XCTAssertTrue(buildPatternURL(patternURLString: "https://example.com")!.hasPrefix(URL(string: "https://example.com")!))
        XCTAssertTrue(buildPatternURL(patternURLString: "https://example.com/")!.hasPrefix(URL(string: "https://example.com/")!))
        XCTAssertTrue(buildPatternURL(patternURLString: "https://example.com/")!.hasPrefix(URL(string: "https://example.com")!))
        XCTAssertTrue(buildPatternURL(patternURLString: "https://example.com/users/:id")!.hasPrefix(URL(string: "https://example.com")!))
        XCTAssertTrue(buildPatternURL(patternURLString: "https://example.com/users/:id")!.hasPrefix(URL(string: "https://example.com/")!))
        XCTAssertTrue(buildPatternURL(patternURLString: "https://example.com/users/:id")!.hasPrefix(URL(string: "https://example.com/users")!))
        XCTAssertTrue(buildPatternURL(patternURLString: "https://example.com/users/:id")!.hasPrefix(URL(string: "https://example.com/users/")!))
        XCTAssertTrue(buildPatternURL(patternURLString: "https://example.com/users/:id")!.hasPrefix(URL(string: "https://example.com/users/10")!))
    }
}
