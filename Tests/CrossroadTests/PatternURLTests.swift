import XCTest
@testable import Crossroad

final class PatternURLTests: XCTestCase {
    func testPatternURL() {
        let checkSameComponents: ((_ string: String) -> Void) = { string in
            let patternURL = PatternURL(string: string)!
            let url = URL(string: string)!
            XCTAssertEqual(patternURL.scheme, url.scheme)
            XCTAssertEqual(patternURL.host, url.host)
            XCTAssertEqual(patternURL.pathComponents, url.pathComponents)
        }

        checkSameComponents("foobar://static")
        checkSameComponents("foobar://foo/bar")
        checkSameComponents("foobar://spam/ham")
        checkSameComponents("foobar://foo/:keyword")

        // URL doesn't like :xxx in host names so check values directly.
        let patternURL = PatternURL(string: "foobar://:keyword")!
        XCTAssertEqual(patternURL.scheme, "foobar")
        XCTAssertEqual(patternURL.host, ":keyword")
        XCTAssertEqual(patternURL.pathComponents, [])
    }

    func testCapitalCase() {
        let subject = PatternURL(string: "FOOBAR://FOO/BAR")!
        XCTAssertEqual(subject.patternString,
                       "FOOBAR://FOO/BAR")
        XCTAssertEqual(subject.scheme, "FOOBAR")
        XCTAssertEqual(subject.host, "FOO")
        XCTAssertEqual(subject.pathComponents, ["/", "BAR"])
    }

    func testParseWithKeyword() {
        let url0 = PatternURL(string: "foobar://search/:keyword")
        XCTAssertEqual(url0?.scheme, "foobar")
        XCTAssertEqual(url0?.host, "search")
        XCTAssertEqual(url0?.pathComponents, ["/", ":keyword"])

        let url1 = PatternURL(string: "foobar://:keyword")
        XCTAssertEqual(url1?.scheme, "foobar")
        XCTAssertEqual(url1?.host, ":keyword")
        XCTAssertEqual(url1?.pathComponents, [])
    }

    func testParseInvalidPattern() {
        func assertShouldFailed(_ string: String) {
            let url0 = PatternURL(string: string)
            XCTAssertNil(url0)
        }

        assertShouldFailed("without_schema")
        assertShouldFailed("invalid_schema://////aaaaaaa")
    }

    func testHasPrefix() {
        XCTAssertTrue(PatternURL(string: "https://example.com")!.hasPrefix(url: URL(string: "https://example.com")!))
        XCTAssertTrue(PatternURL(string: "https://example.com/")!.hasPrefix(url: URL(string: "https://example.com/")!))
        XCTAssertTrue(PatternURL(string: "https://example.com/")!.hasPrefix(url: URL(string: "https://example.com")!))
        XCTAssertTrue(PatternURL(string: "https://example.com/users/:id")!.hasPrefix(url: URL(string: "https://example.com")!))
        XCTAssertTrue(PatternURL(string: "https://example.com/users/:id")!.hasPrefix(url: URL(string: "https://example.com/")!))
        XCTAssertTrue(PatternURL(string: "https://example.com/users/:id")!.hasPrefix(url: URL(string: "https://example.com/users")!))
        XCTAssertTrue(PatternURL(string: "https://example.com/users/:id")!.hasPrefix(url: URL(string: "https://example.com/users/")!))
        XCTAssertFalse(PatternURL(string: "https://example.com/users/:id")!.hasPrefix(url: URL(string: "https://example.com/users/10")!))
    }
}
