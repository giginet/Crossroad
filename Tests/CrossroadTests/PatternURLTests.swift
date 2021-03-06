import XCTest
@testable import Crossroad

final class PatternURLTests: XCTestCase {
    func testPatternURL() {
        let checkSameComponents: ((_ string: String) -> Void) = { string in
            let patternURL = buildPatternURL(patternURLString: string)!
            let url = URL(string: string)!
            XCTAssertEqual(patternURL.pathComponent, [url.host!] + url.pathComponents)
        }

        checkSameComponents("foobar://static")
        checkSameComponents("foobar://foo/bar")
        checkSameComponents("foobar://spam/ham")
        checkSameComponents("foobar://foo/:keyword")
    }

//    func testCapitalCase() {
//        let subject = buildPatternURL(patternURLString: "FOOBAR://FOO/BAR")!
//        XCTAssertEqual(subject.patternString,
//                       "FOOBAR://FOO/BAR")
//        XCTAssertEqual(subject.scheme, "FOOBAR")
//        XCTAssertEqual(subject.host, "FOO")
//        XCTAssertEqual(subject.pathComponents, ["/", "BAR"])
//    }
//
//    func testParseWithKeyword() {
//        let url0 = buildPatternURL(patternURLString: "foobar://search/:keyword")
//        XCTAssertEqual(url0?.scheme, "foobar")
//        XCTAssertEqual(url0?.host, "search")
//        XCTAssertEqual(url0?.pathComponents, ["/", ":keyword"])
//
//        let url1 = buildPatternURL(patternURLString: "foobar://:keyword")
//        XCTAssertEqual(url1?.scheme, "foobar")
//        XCTAssertEqual(url1?.host, ":keyword")
//        XCTAssertEqual(url1?.pathComponents, [])
//    }

    func testParseInvalidPattern() {
        func assertShouldFailed(_ string: String, line: Int) {
            let url0 = buildPatternURL(patternURLString: string)
            XCTAssertNil(url0)
        }

        assertShouldFailed("without_schema", line: #line)
        assertShouldFailed("invalid_schema://////aaaaaaa", line: #line)
    }

    func testMatch() {
        XCTAssertTrue(buildPatternURL(patternURLString: "https://example.com")!.match(URL(string: "https://example.com")!))
        XCTAssertTrue(buildPatternURL(patternURLString: "https://example.com/")!.match(URL(string: "https://example.com/")!))
        XCTAssertTrue(buildPatternURL(patternURLString: "https://example.com/")!.match(URL(string: "https://example.com")!))
        XCTAssertTrue(buildPatternURL(patternURLString: "https://example.com/users/:id")!.match(URL(string: "https://example.com")!))
        XCTAssertTrue(buildPatternURL(patternURLString: "https://example.com/users/:id")!.match(URL(string: "https://example.com/")!))
        XCTAssertTrue(buildPatternURL(patternURLString: "https://example.com/users/:id")!.match(URL(string: "https://example.com/users")!))
        XCTAssertTrue(buildPatternURL(patternURLString: "https://example.com/users/:id")!.match(URL(string: "https://example.com/users/")!))
        XCTAssertFalse(buildPatternURL(patternURLString: "https://example.com/users/:id")!.match(URL(string: "https://example.com/users/10")!))
    }
}
