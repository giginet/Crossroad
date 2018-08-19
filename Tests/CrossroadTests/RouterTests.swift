import Foundation
import XCTest
import Crossroad

final class RouterTest: XCTestCase {
    let scheme = "foobar"

    func testCanRespond() {
        let router = SimpleRouter(scheme: scheme)
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
        XCTAssertFalse(router.responds(to: URL(string: "static")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo/bar")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo/10000")!))
        XCTAssertFalse(router.responds(to: URL(string: "aaa/bbb")!))
        XCTAssertFalse(router.responds(to: URL(string: "spam/ham")!))
    }

    func testCanRespondWithoutScheme() {
        let router = SimpleRouter(scheme: scheme)
        router.register([
            ("static", { _ in true }),
            ("foo/bar", { _ in true }),
            ("spam/ham", { _ in false }),
            (":keyword", { _ in true }),
            ("foo/:keyword", { _ in true }),
            ])
        XCTAssertTrue(router.responds(to: URL(string: "foobar://static")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo/bar")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo/10000")!))
        XCTAssertFalse(router.responds(to: URL(string: "notfoobar://aaa/bbb")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://spam/ham")!))
        XCTAssertFalse(router.responds(to: URL(string: "static")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo/bar")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo/10000")!))
        XCTAssertFalse(router.responds(to: URL(string: "aaa/bbb")!))
        XCTAssertFalse(router.responds(to: URL(string: "spam/ham")!))
    }

    func testHandle() {
        let router = SimpleRouter(scheme: scheme)
        let expectation = self.expectation(description: "Should called handler four times")
        expectation.expectedFulfillmentCount = 4
        router.register([
            ("foobar://static", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://static")!)
                expectation.fulfill()
                return true
            }),
            ("foobar://foo/bar", { context in
                XCTAssertEqual(context.parameters.fetch(for: "param0"), 123)
                XCTAssertEqual(context.url, URL(string: "foobar://foo/bar?param0=123")!)
                expectation.fulfill()
                return true
            }),
            ("foobar://:keyword", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://hoge")!)
                XCTAssertEqual(context.arguments.keyword, "hoge")
                expectation.fulfill()
                return true
            }),
            ("foobar://foo/:keyword/:keyword2", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://foo/hoge/fuga")!)
                XCTAssertEqual(context.arguments.keyword, "hoge")
                XCTAssertEqual(context.arguments.keyword2, "fuga")
                expectation.fulfill()
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://static")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/bar?param0=123")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://hoge")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/hoge/fuga")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foobar://spam/ham")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "notfoobar://static")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "static")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/bar?param0=123")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "hoge")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/hoge/fuga")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "spam/ham")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandleWithoutScheme() {
        let router = SimpleRouter(scheme: scheme)
        let expectation = self.expectation(description: "Should called handler four times")
        expectation.expectedFulfillmentCount = 4
        router.register([
            ("static", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://static")!)
                expectation.fulfill()
                return true
            }),
            ("foo/bar", { context in
                XCTAssertEqual(context.parameters.param0, 123)
                XCTAssertEqual(context.url, URL(string: "foobar://foo/bar?param0=123")!)
                expectation.fulfill()
                return true
            }),
            (":keyword", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://hoge")!)
                XCTAssertEqual(context.arguments.keyword, "hoge")
                expectation.fulfill()
                return true
            }),
            ("foo/:keyword/:keyword2", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://foo/hoge/fuga")!)
                XCTAssertEqual(context.arguments.keyword, "hoge")
                XCTAssertEqual(context.arguments.keyword2, "fuga")
                expectation.fulfill()
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://static")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/bar?param0=123")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://hoge")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/hoge/fuga")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foobar://spam/ham")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "notfoobar://static")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "static")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/bar?param0=123")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "hoge")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/hoge/fuga")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "spam/ham")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandlerWithSamePatterns() {
        let router = SimpleRouter(scheme: scheme)
        let idExpectation = self.expectation(description: "Should called handler with ID")
        let keywordExpectation = self.expectation(description: "Should called handler with keyword")
        router.register([
            ("foobar://foo/:id", { context in
                guard let id: Int = context.arguments.id else {
                    return false
                }
                XCTAssertEqual(context.url, URL(string: "foobar://foo/42")!)
                XCTAssertEqual(id, 42)
                idExpectation.fulfill()
                return true
            }),
            ("foobar://foo/:keyword", { context in
                let keyword: String = context.arguments.keyword
                XCTAssertEqual(context.url, URL(string: "foobar://foo/bar")!)
                XCTAssertEqual(keyword, "bar")
                keywordExpectation.fulfill()
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/42")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/bar")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/42")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/bar")!))
        wait(for: [idExpectation, keywordExpectation], timeout: 2.0)
    }

    func testHandlerWithSamePatternsWithoutScheme() {
        let router = SimpleRouter(scheme: scheme)
        let idExpectation = self.expectation(description: "Should called handler with ID")
        let keywordExpectation = self.expectation(description: "Should called handler with keyword")
        router.register([
            ("foo/:id", { context in
                guard let id: Int = context.arguments.id else {
                    return false
                }
                XCTAssertEqual(context.url, URL(string: "foobar://foo/42")!)
                XCTAssertEqual(id, 42)
                idExpectation.fulfill()
                return true
            }),
            ("foo/:keyword", { context in
                let keyword: String = context.arguments.keyword
                XCTAssertEqual(context.url, URL(string: "foobar://foo/bar")!)
                XCTAssertEqual(keyword, "bar")
                keywordExpectation.fulfill()
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/42")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/bar")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/42")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/bar")!))
        wait(for: [idExpectation, keywordExpectation], timeout: 2.0)
    }

    func testHandleReturnsFalse() {
        let router = SimpleRouter(scheme: scheme)
        let expectation = self.expectation(description: "Should called handler twice")
        expectation.expectedFulfillmentCount = 2
        router.register([
            ("foobar://foo/bar", { _ in
                expectation.fulfill()
                return false
            }),
            ("foobar://foo/:keyword", { context in
                XCTAssertEqual(context.arguments.keyword, "bar")
                expectation.fulfill()
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/bar")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/bar")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandleReturnsFalseWithoutScheme() {
        let router = SimpleRouter(scheme: scheme)
        let expectation = self.expectation(description: "Should called handler twice")
        expectation.expectedFulfillmentCount = 2
        router.register([
            ("foo/bar", { _ in
                expectation.fulfill()
                return false
            }),
            ("foo/:keyword", { context in
                XCTAssertEqual(context.arguments.keyword, "bar")
                expectation.fulfill()
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/bar")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/bar")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testWithUserInfo() {
        struct UserInfo {
            let value: Int
        }
        let router = Router<UserInfo>(scheme: scheme)
        var userInfo: UserInfo?
        router.register([
            ("foobar://static", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://static")!)
                userInfo = context.userInfo
                return true
            }),
        ])
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://static")!, userInfo: UserInfo(value: 42)))
        XCTAssertFalse(router.openIfPossible(URL(string: "static")!, userInfo: UserInfo(value: 42)))
        XCTAssertEqual(userInfo?.value, 42)
    }

    func testWithUserInfoWithoutScheme() {
        struct UserInfo {
            let value: Int
        }
        let router = Router<UserInfo>(scheme: scheme)
        var userInfo: UserInfo?
        router.register([
            ("static", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://static")!)
                userInfo = context.userInfo
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://static")!, userInfo: UserInfo(value: 42)))
        XCTAssertFalse(router.openIfPossible(URL(string: "static")!, userInfo: UserInfo(value: 42)))
        XCTAssertEqual(userInfo?.value, 42)
    }
}
