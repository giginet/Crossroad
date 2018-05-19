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
        var openedCount = 0
        router.register([
            ("foobar://static", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://static")!)
                openedCount += 1
                return true
            }),
            ("foobar://foo/bar", { context in
                XCTAssertEqual(context.parameter(for: "param0"), 123)
                XCTAssertEqual(context.url, URL(string: "foobar://foo/bar?param0=123")!)
                openedCount += 1
                return true
            }),
            ("foobar://:keyword", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://hoge")!)
                XCTAssertEqual(try? context.argument(for: "keyword"), "hoge")
                openedCount += 1
                return true
            }),
            ("foobar://foo/:keyword", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://foo/hoge")!)
                XCTAssertEqual(try? context.argument(for: "keyword"), "hoge")
                openedCount += 1
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://static")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/bar?param0=123")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://hoge")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/hoge")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foobar://spam/ham")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "notfoobar://static")!))
        XCTAssertEqual(openedCount, 4)
    }

    func testHandleReturnsFalse() {
        let router = SimpleRouter(scheme: schema)
        var matchesRoutes = 0
        router.register([
            ("foobar://foo/bar", { _ in
                matchesRoutes += 1
                return false
            }),
            ("foobar://foo/:keyword", { context in
                matchesRoutes += 1
                XCTAssertEqual(try? context.argument(for: "keyword"), "bar")
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/bar")!))
        XCTAssertEqual(matchesRoutes, 2)
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
