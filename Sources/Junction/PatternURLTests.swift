import Foundation
import XCTest
@testable import Junction

final class PatternURLTests: XCTestCase {
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
}
