import XCTest
@testable import Crossroad

final class PatternURLTests: XCTestCase {
    func testPatternURL() {
        let checkSameComponents: ((_ string: String) -> Void) = { string in
            let patternURL = buildPatternURL(patternURLString: string)!
            let url = URL(string: string)!
            XCTAssertEqual(patternURL.pathComponent, url.componentsWithHost)
        }

        checkSameComponents("foobar://static")
        checkSameComponents("foobar://foo/bar")
        checkSameComponents("foobar://spam/ham")
        checkSameComponents("foobar://foo/:keyword")
    }

    func testCapitalCase() throws {
        let subject = buildPatternURL(patternURLString: "FOOBAR://FOO/BAR")!
        let patternURL: AbsolutePatternURL = try XCTUnwrap(subject as? AbsolutePatternURL)
        XCTAssertEqual(patternURL.prefix, .scheme("FOOBAR"))
        XCTAssertEqual(patternURL.pathComponent, ["FOO", "BAR"])
    }

    func testParseWithKeyword() throws {
        let url0 = buildPatternURL(patternURLString: "foobar://search/:keyword")
        let patternURL0: AbsolutePatternURL = try XCTUnwrap(url0 as? AbsolutePatternURL)
        XCTAssertEqual(patternURL0.prefix, .scheme("foobar"))
        XCTAssertEqual(patternURL0.pathComponent, ["search", ":keyword"])

        let url1 = buildPatternURL(patternURLString: "foobar://:keyword")
        let patternURL1: AbsolutePatternURL = try XCTUnwrap(url1 as? AbsolutePatternURL)
        XCTAssertEqual(patternURL1.prefix, .scheme("foobar"))
        XCTAssertEqual(patternURL1.pathComponent, [":keyword"])
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
