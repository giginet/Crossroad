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
            ("FOOBAR://SPAM/HAM", { _ in false }),
            ("foobar://:keyword", { _ in true }),
            ("foobar://foo/:keyword", { _ in true }),
            ])
        XCTAssertTrue(router.responds(to: URL(string: "foobar://static")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo/bar")!))
        XCTAssertTrue(router.responds(to: URL(string: "FOOBAR://FOO/BAR")!))
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

    func testCanRespondWithCapitalCase() {
        let router = SimpleRouter(scheme: "FOOBAR")
        router.register([
            ("FOOBAR://STATIC", { _ in true }),
            ("FOOBAR://FOO/BAR", { _ in true }),
            ("FOOBAR://SPAM/HAM", { _ in false }),
            ("FOOBAR://:keyword", { _ in true }),
            ("FOOBAR://FOO/:keyword", { _ in true }),
            ])
        XCTAssertTrue(router.responds(to: URL(string: "foobar://sTATic")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo/bar")!))
        XCTAssertTrue(router.responds(to: URL(string: "FOOBAR://FOO/BAR")!))
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

    func testCanRespondWithURLPrefix() {
        let router = SimpleRouter(url: URL(string: "https://example.com")!)
        router.register([
            ("https://example.com/static", { _ in true }),
            ("https://example.com/foo/bar", { _ in true }),
            ("HTTPS://EXAMPLE.COM/SPAM/HAM", { _ in false }),
            ("https://example.com/:keyword", { _ in true }),
            ("https://example.com/foo/:keyword", { _ in true }),
            ])
        XCTAssertTrue(router.responds(to: URL(string: "https://example.com/static")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://example.com/foo")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://example.com/foo/bar")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://example.com/foo/10000")!))
        XCTAssertFalse(router.responds(to: URL(string: "https://example.com/aaa/bbb")!))
        XCTAssertFalse(router.responds(to: URL(string: "nothttps://example.com/aaa/bbb")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://example.com/spam/ham")!))
        XCTAssertFalse(router.responds(to: URL(string: "static")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo/bar")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo/10000")!))
        XCTAssertFalse(router.responds(to: URL(string: "aaa/bbb")!))
        XCTAssertFalse(router.responds(to: URL(string: "spam/ham")!))
    }

    func testCanRespondWithoutPrefix() {
        let router = SimpleRouter(scheme: scheme)
        router.register([
            ("static", { _ in true }),
            ("foo/bar", { _ in true }),
            ("SPAM/HAM", { _ in false }),
            (":keyword", { _ in true }),
            ("foo/:keyword", { _ in true }),
            ])
        XCTAssertTrue(router.responds(to: URL(string: "foobar://static")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo/bar")!))
        XCTAssertTrue(router.responds(to: URL(string: "FOOBAR://FOO/BAR")!))
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

    func testCanRespondWithRelativePath() {
        let router = SimpleRouter(scheme: scheme)
        router.register([
            ("/static", { _ in true }),
            ("/foo/bar", { _ in true }),
            ("/SPAM/HAM", { _ in false }),
            ("/:keyword", { _ in true }),
            ("/foo/:keyword", { _ in true }),
            ])
        XCTAssertTrue(router.responds(to: URL(string: "foobar://static")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo/bar")!))
        XCTAssertTrue(router.responds(to: URL(string: "FOOBAR://FOO/BAR")!))
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

    func testCanRespondWithoutPrefixWithURLPrefix() {
        let router = SimpleRouter(url: URL(string: "https://example.com/")!)
        router.register([
            ("static", { _ in true }),
            ("foo/bar", { _ in true }),
            ("SPAM/HAM", { _ in false }),
            (":keyword", { _ in true }),
            ("foo/:keyword", { _ in true }),
            ])
        XCTAssertTrue(router.responds(to: URL(string: "https://example.com/static")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://example.com/foo")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://example.com/foo/bar")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://example.com/foo/10000")!))
        XCTAssertFalse(router.responds(to: URL(string: "nothttps://example.com/aaa/bbb")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://example.com/spam/ham")!))
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
            ("foobar://foo/:keyword/:keyword2", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://foo/hoge/fuga")!)
                XCTAssertEqual(try? context.argument(for: "keyword"), "hoge")
                XCTAssertEqual(try? context.argument(for: "keyword2"), "fuga")
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

    func testHandleWithURLPrefix() {
        let router = SimpleRouter(url: URL(string: "https://example.com")!)
        let expectation = self.expectation(description: "Should called handler four times")
        expectation.expectedFulfillmentCount = 4
        router.register([
            ("https://example.com/static", { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/static")!)
                expectation.fulfill()
                return true
            }),
            ("https://example.com/foo/bar", { context in
                XCTAssertEqual(context.parameter(for: "param0"), 123)
                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/bar?param0=123")!)
                expectation.fulfill()
                return true
            }),
            ("https://example.com/:keyword", { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/hoge")!)
                XCTAssertEqual(try? context.argument(for: "keyword"), "hoge")
                expectation.fulfill()
                return true
            }),
            ("https://example.com/foo/:keyword/:keyword2", { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/hoge/fuga")!)
                XCTAssertEqual(try? context.argument(for: "keyword"), "hoge")
                XCTAssertEqual(try? context.argument(for: "keyword2"), "fuga")
                expectation.fulfill()
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/static")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/foo/bar?param0=123")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/hoge")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/foo/hoge/fuga")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "https://example.com/spam/ham")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "nothttps://example.com/static")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "static")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/bar?param0=123")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "hoge")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/hoge/fuga")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "spam/ham")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandleWithoutPrefix() {
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
                XCTAssertEqual(context.parameter(for: "param0"), 123)
                XCTAssertEqual(context.url, URL(string: "foobar://foo/bar?param0=123")!)
                expectation.fulfill()
                return true
            }),
            (":keyword", { context in
                XCTAssertEqual(context.url, URL(string: "FOOBAR://HOGE")!)
                XCTAssertEqual(try? context.argument(for: "keyword"), "HOGE")
                expectation.fulfill()
                return true
            }),
            ("foo/:keyword/:keyword2", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://foo/hoge/fuga")!)
                XCTAssertEqual(try? context.argument(for: "keyword"), "hoge")
                XCTAssertEqual(try? context.argument(for: "keyword2"), "fuga")
                expectation.fulfill()
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://static")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/bar?param0=123")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "FOOBAR://HOGE")!))
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

    func testHandleWithSlashPrefix() {
        let router = SimpleRouter(scheme: scheme)
        let expectation = self.expectation(description: "Should called handler four times")
        expectation.expectedFulfillmentCount = 4
        router.register([
            ("/static", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://static")!)
                expectation.fulfill()
                return true
            }),
            ("/foo/bar", { context in
                XCTAssertEqual(context.parameter(for: "param0"), 123)
                XCTAssertEqual(context.url, URL(string: "foobar://foo/bar?param0=123")!)
                expectation.fulfill()
                return true
            }),
            ("/:keyword", { context in
                XCTAssertEqual(context.url, URL(string: "FOOBAR://HOGE")!)
                XCTAssertEqual(try? context.argument(for: "keyword"), "HOGE")
                expectation.fulfill()
                return true
            }),
            ("/foo/:keyword/:keyword2", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://foo/hoge/fuga")!)
                XCTAssertEqual(try? context.argument(for: "keyword"), "hoge")
                XCTAssertEqual(try? context.argument(for: "keyword2"), "fuga")
                expectation.fulfill()
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://static")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/bar?param0=123")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "FOOBAR://HOGE")!))
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

    func testHandleWithoutPrefixWithURLPrefix() {
        let router = SimpleRouter(url: URL(string: "https://example.com")!)
        let expectation = self.expectation(description: "Should called handler four times")
        expectation.expectedFulfillmentCount = 4
        router.register([
            ("static", { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/static")!)
                expectation.fulfill()
                return true
            }),
            ("foo/bar", { context in
                XCTAssertEqual(context.parameter(for: "param0"), 123)
                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/bar?param0=123")!)
                expectation.fulfill()
                return true
            }),
            (":keyword", { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/HOGE")!)
                XCTAssertEqual(try? context.argument(for: "keyword"), "HOGE")
                expectation.fulfill()
                return true
            }),
            ("foo/:keyword/:keyword2", { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/hoge/fuga")!)
                XCTAssertEqual(try? context.argument(for: "keyword"), "hoge")
                XCTAssertEqual(try? context.argument(for: "keyword2"), "fuga")
                expectation.fulfill()
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/static")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/foo/bar?param0=123")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/HOGE")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/foo/hoge/fuga")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "https://example.com/spam/ham")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "nothttps://example.com/static")!))
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
                guard let id: Int = try? context.argument(for: "id") else {
                    return false
                }
                XCTAssertEqual(context.url, URL(string: "foobar://foo/42")!)
                XCTAssertEqual(id, 42)
                idExpectation.fulfill()
                return true
            }),
            ("foobar://foo/:keyword", { context in
                let keyword: String = try! context.argument(for: "keyword")
                XCTAssertEqual(context.url, URL(string: "FOOBAR://FOO/BAR")!)
                XCTAssertEqual(keyword, "BAR")
                keywordExpectation.fulfill()
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/42")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "FOOBAR://FOO/BAR")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/42")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/bar")!))
        wait(for: [idExpectation, keywordExpectation], timeout: 2.0)
    }

    func testHandlerWithSamePatternsWithURLPrefix() {
        let router = SimpleRouter(url: URL(string: "https://example.com/")!)
        let idExpectation = self.expectation(description: "Should called handler with ID")
        let keywordExpectation = self.expectation(description: "Should called handler with keyword")
        router.register([
            ("https://example.com/foo/:id", { context in
                guard let id: Int = try? context.argument(for: "id") else {
                    return false
                }
                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/42")!)
                XCTAssertEqual(id, 42)
                idExpectation.fulfill()
                return true
            }),
            ("https://example.com/foo/:keyword", { context in
                let keyword: String = try! context.argument(for: "keyword")
                XCTAssertEqual(context.url, URL(string: "https://example.com/FOO/BAR")!)
                XCTAssertEqual(keyword, "BAR")
                keywordExpectation.fulfill()
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/foo/42")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/FOO/BAR")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/42")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/bar")!))
        wait(for: [idExpectation, keywordExpectation], timeout: 2.0)
    }

    func testHandlerWithSamePatternsWithoutPrefix() {
        let router = SimpleRouter(scheme: scheme)
        let idExpectation = self.expectation(description: "Should called handler with ID")
        let keywordExpectation = self.expectation(description: "Should called handler with keyword")
        router.register([
            ("foo/:id", { context in
                guard let id: Int = try? context.argument(for: "id") else {
                    return false
                }
                XCTAssertEqual(context.url, URL(string: "foobar://foo/42")!)
                XCTAssertEqual(id, 42)
                idExpectation.fulfill()
                return true
            }),
            ("foo/:keyword", { context in
                let keyword: String = try! context.argument(for: "keyword")
                XCTAssertEqual(context.url, URL(string: "FOOBAR://FOO/BAR")!)
                XCTAssertEqual(keyword, "BAR")
                keywordExpectation.fulfill()
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/42")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "FOOBAR://FOO/BAR")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/42")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/bar")!))
        wait(for: [idExpectation, keywordExpectation], timeout: 2.0)
    }

    func testHandlerWithSamePatternsWithoutPrefixWithURLPrefix() {
        let router = SimpleRouter(url: URL(string: "https://example.com/")!)
        let idExpectation = self.expectation(description: "Should called handler with ID")
        let keywordExpectation = self.expectation(description: "Should called handler with keyword")
        router.register([
            ("foo/:id", { context in
                guard let id: Int = try? context.argument(for: "id") else {
                    return false
                }
                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/42")!)
                XCTAssertEqual(id, 42)
                idExpectation.fulfill()
                return true
            }),
            ("foo/:keyword", { context in
                let keyword: String = try! context.argument(for: "keyword")
                XCTAssertEqual(context.url, URL(string: "https://example.com/FOO/BAR")!)
                XCTAssertEqual(keyword, "BAR")
                keywordExpectation.fulfill()
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/foo/42")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/FOO/BAR")!))
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
            ("/foo/:keyword", { context in
                XCTAssertEqual(try? context.argument(for: "keyword"), "BAR")
                expectation.fulfill()
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "FOOBAR://FOO/BAR")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/bar")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandleReturnsFalseWithURLPrefix() {
        let router = SimpleRouter(url: URL(string: "https://example.com/")!)
        let expectation = self.expectation(description: "Should called handler twice")
        expectation.expectedFulfillmentCount = 2
        router.register([
            ("https://example.com/foo/bar", { _ in
                expectation.fulfill()
                return false
            }),
            ("/foo/:keyword", { context in
                XCTAssertEqual(try? context.argument(for: "keyword"), "BAR")
                expectation.fulfill()
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/FOO/BAR")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/bar")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandleReturnsFalseWithoutPrefix() {
        let router = SimpleRouter(scheme: scheme)
        let expectation = self.expectation(description: "Should called handler twice")
        expectation.expectedFulfillmentCount = 2
        router.register([
            ("foo/bar", { _ in
                expectation.fulfill()
                return false
            }),
            ("/foo/:keyword", { context in
                XCTAssertEqual(try? context.argument(for: "keyword"), "BAR")
                expectation.fulfill()
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "FOOBAR://FOO/BAR")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/bar")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandleCapitalCasedHostKeyword() {
        let router = SimpleRouter(scheme: scheme)
        let expectation = self.expectation(description: "Should called handler")
        router.register([
            (":keyword", { context in
                XCTAssertEqual(context.url.absoluteString, "FOOBAR://FOO")
                XCTAssertEqual(try! context.argument(for: "keyword"), "FOO")
                expectation.fulfill()
                return true
            }),
        ])
        XCTAssertTrue(router.openIfPossible(URL(string: "FOOBAR://FOO")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandleReturnsFalseWithoutPrefixWithURLPrefix() {
        let router = SimpleRouter(url: URL(string: "https://example.com/")!)
        let expectation = self.expectation(description: "Should called handler twice")
        expectation.expectedFulfillmentCount = 2
        router.register([
            ("foo/bar", { _ in
                expectation.fulfill()
                return false
            }),
            ("/foo/:keyword", { context in
                XCTAssertEqual(try? context.argument(for: "keyword"), "BAR")
                expectation.fulfill()
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/FOO/BAR")!))
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

    func testWithUserInfoWithURLPrefix() {
        struct UserInfo {
            let value: Int
        }
        let router = Router<UserInfo>(url: URL(string: "https://example.com/")!)
        var userInfo: UserInfo?
        router.register([
            ("https://example.com/static", { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/static")!)
                userInfo = context.userInfo
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/static")!, userInfo: UserInfo(value: 42)))
        XCTAssertFalse(router.openIfPossible(URL(string: "static")!, userInfo: UserInfo(value: 42)))
        XCTAssertEqual(userInfo?.value, 42)
    }

    func testWithUserInfoWithoutPrefix() {
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

    func testWithUserInfoWithoutPrefixWithURLPrefix() {
        struct UserInfo {
            let value: Int
        }
        let router = Router<UserInfo>(url: URL(string: "https://example.com/")!)
        var userInfo: UserInfo?
        router.register([
            ("static", { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/static")!)
                userInfo = context.userInfo
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/static")!, userInfo: UserInfo(value: 42)))
        XCTAssertFalse(router.openIfPossible(URL(string: "static")!, userInfo: UserInfo(value: 42)))
        XCTAssertEqual(userInfo?.value, 42)
    }
}
