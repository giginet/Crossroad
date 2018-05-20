import Foundation
import XCTest
import Crossroad

final class RouterTest: XCTestCase {
    let schema = "foobar"

    func testCanRespond() {
        let router = SimpleRouter(scheme: schema)
        router.register([
            ("foobar://static", { _ in true }),
            ("foobar://foo/bar", { _ in true }),
            ("foobar://spam/ham", { _ in false }),
            ("foobar://:keyword", { _ in true }),
            ("foobar://foo/:keyword", { _ in true }),
            ])
        XCTAssertTrue(router.responds(to: URL(string: "foobar://static")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo/bar")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo/10000")!))
        XCTAssertFalse(router.responds(to: URL(string: "foobar://aaa/bbb")!))
        XCTAssertFalse(router.responds(to: URL(string: "notfoobar://aaa/bbb")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://spam/ham")!))
    }

    func testHandle() {
        let router = SimpleRouter(scheme: schema)
        let expectation = self.expectation(description: "Should called handler four times")
        expectation.expectedFulfillmentCount = 4
        router.register([
            ("foobar://static", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://static")!)
                expectation.fulfill()
                return true
            }),
            ("foobar://foo/bar", { context in
                XCTAssertEqual(context.parameter(for: "param0"), 123)
                XCTAssertEqual(context.url, URL(string: "foobar://foo/bar?param0=123")!)
                expectation.fulfill()
                return true
            }),
            ("foobar://:keyword", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://hoge")!)
                XCTAssertEqual(try? context.argument(for: "keyword"), "hoge")
                expectation.fulfill()
                return true
            }),
            ("foobar://foo/:keyword", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://foo/hoge")!)
                XCTAssertEqual(try? context.argument(for: "keyword"), "hoge")
                expectation.fulfill()
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://static")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/bar?param0=123")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://hoge")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/hoge")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foobar://spam/ham")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "notfoobar://static")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandleReturnsFalse() {
        let router = SimpleRouter(scheme: schema)
        let expectation = self.expectation(description: "Should called handler twice")
        expectation.expectedFulfillmentCount = 2
        router.register([
            ("foobar://foo/bar", { _ in
                expectation.fulfill()
                return false
            }),
            ("foobar://foo/:keyword", { context in
                XCTAssertEqual(try? context.argument(for: "keyword"), "bar")
                expectation.fulfill()
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/bar")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testWithUserInfo() {
        struct UserInfo {
            let value: Int
        }
        let router = Router<UserInfo>(scheme: schema)
        var userInfo: UserInfo? = nil
        router.register([
            ("foobar://static", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://static")!)
                userInfo = context.userInfo
                return true
            }),
        ])
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://static")!, userInfo: UserInfo(value: 42)))
        XCTAssertEqual(userInfo?.value, 42)
    }
}
