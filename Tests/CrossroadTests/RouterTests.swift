import XCTest
import Crossroad

final class RouterTest: XCTestCase {
    private let scheme: LinkSource = .customURLScheme("foobar")

    func testCanRespond() throws {
        let router = try SimpleRouter(accepts: [scheme]) { route in
            route("foobar://static") { _ in true }
            route("foobar://foo/bar") { _ in true }
            route("foobar://SPAM/HAM") { _ in false }
            route("foobar://:keyword") { _ in true }
            route("foobar://foo/:keyword") { _ in true }
        }
        XCTAssertTrue(router.responds(to: URL(string: "foobar://static")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo/bar")!))
        XCTAssertTrue(router.responds(to: URL(string: "FOOBAR://FOO/BAR")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo/10000")!))
        XCTAssertFalse(router.responds(to: URL(string: "foobar://aaa/bbb")!))
        XCTAssertFalse(router.responds(to: URL(string: "foobar://spam/ham")!))
        XCTAssertFalse(router.responds(to: URL(string: "foobar://SPAM/ham")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://SPAM/HAM")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://spam/HAM")!))
        XCTAssertFalse(router.responds(to: URL(string: "notfoobar://aaa/bbb")!))
        XCTAssertFalse(router.responds(to: URL(string: "foobar://spam/ham")!))
        XCTAssertFalse(router.responds(to: URL(string: "static")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo/bar")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo/10000")!))
        XCTAssertFalse(router.responds(to: URL(string: "aaa/bbb")!))
    }

    func testCanRespondWithCapitalCase() throws {
        let router = try SimpleRouter(accepts: [.customURLScheme("FOOBAR")]) { route in
            route("FOOBAR://STATIC") { _ in true }
            route("FOOBAR://FOO/BAR") { _ in true }
            route("FOOBAR://SPAM/HAM") { _ in false }
            route("FOOBAR://:keyword") { _ in true }
            route("FOOBAR://FOO/:keyword") { _ in true }
        }
        XCTAssertTrue(router.responds(to: URL(string: "foobar://sTATic")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo/bar")!))
        XCTAssertTrue(router.responds(to: URL(string: "FOOBAR://FOO/BAR")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo/10000")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://FOO/10000")!))
        XCTAssertFalse(router.responds(to: URL(string: "foobar://aaa/bbb")!))
        XCTAssertFalse(router.responds(to: URL(string: "notfoobar://aaa/bbb")!))
        XCTAssertFalse(router.responds(to: URL(string: "foobar://spam/ham")!))
        XCTAssertFalse(router.responds(to: URL(string: "static")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo/bar")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo/10000")!))
        XCTAssertFalse(router.responds(to: URL(string: "aaa/bbb")!))
        XCTAssertFalse(router.responds(to: URL(string: "spam/ham")!))
    }

    func testCanRespondWithURLPrefix() throws {
        let router = try SimpleRouter(accepts: [.universalLink(URL(string: "https://example.com")!)]) { route in
            route("https://example.com/static") { _ in true }
            route("https://example.com/foo/bar") { _ in true }
            route("https://example.com/SPAM/HAM") { _ in false }
            route("https://example.com/:keyword") { _ in true }
            route("https://example.com/foo/:keyword") { _ in true }
        }
        XCTAssertTrue(router.responds(to: URL(string: "https://example.com/static")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://example.com/foo")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://example.com/foo/bar")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://example.com/foo/10000")!))
        XCTAssertFalse(router.responds(to: URL(string: "https://example.com/FOO/10000")!))
        XCTAssertFalse(router.responds(to: URL(string: "https://example.com/aaa/bbb")!))
        XCTAssertFalse(router.responds(to: URL(string: "nothttps://example.com/aaa/bbb")!))
        XCTAssertFalse(router.responds(to: URL(string: "https://example.com/spam/ham")!))
        XCTAssertFalse(router.responds(to: URL(string: "static")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo/bar")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo/10000")!))
        XCTAssertFalse(router.responds(to: URL(string: "aaa/bbb")!))
        XCTAssertFalse(router.responds(to: URL(string: "spam/ham")!))
    }

    func testCanRespondWithoutPrefix() throws {
        let router = try SimpleRouter(accepts: [scheme]) { route in
            route("static") { _ in true }
            route("foo/bar") { _ in true }
            route("SPAM/HAM") { _ in false }
            route(":keyword") { _ in true }
            route("foo/:keyword") { _ in true }
        }
        XCTAssertTrue(router.responds(to: URL(string: "foobar://static")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo/bar")!))
        XCTAssertTrue(router.responds(to: URL(string: "FOOBAR://FOO/BAR")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo/10000")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://FOO/10000")!))
        XCTAssertFalse(router.responds(to: URL(string: "notfoobar://aaa/bbb")!))
        XCTAssertFalse(router.responds(to: URL(string: "foobar://spam/ham")!))
        XCTAssertFalse(router.responds(to: URL(string: "static")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo/bar")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo/10000")!))
        XCTAssertFalse(router.responds(to: URL(string: "aaa/bbb")!))
        XCTAssertFalse(router.responds(to: URL(string: "spam/ham")!))
    }

    func testCanRespondWithRelativePath() throws {
        let router = try SimpleRouter(accepts: [scheme]) { route in
            route("/static") { _ in true }
            route("/foo/bar") { _ in true }
            route("/SPAM/HAM") { _ in false }
            route("/:keyword") { _ in true }
            route("/foo/:keyword") { _ in true }
        }
        XCTAssertTrue(router.responds(to: URL(string: "foobar://static")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo/bar")!))
        XCTAssertTrue(router.responds(to: URL(string: "FOOBAR://FOO/BAR")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://foo/10000")!))
        XCTAssertTrue(router.responds(to: URL(string: "foobar://FOO/10000")!))
        XCTAssertFalse(router.responds(to: URL(string: "notfoobar://aaa/bbb")!))
        XCTAssertFalse(router.responds(to: URL(string: "foobar://spam/ham")!))
        XCTAssertFalse(router.responds(to: URL(string: "static")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo/bar")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo/10000")!))
        XCTAssertFalse(router.responds(to: URL(string: "aaa/bbb")!))
        XCTAssertFalse(router.responds(to: URL(string: "spam/ham")!))
    }

    func testCanRespondWithoutPrefixWithURLPrefix() throws {
        let router = try SimpleRouter(accepts: [.universalLink(URL(string: "https://example.com/")!)]) { route in
            route("static") { _ in true }
            route("foo/bar") { _ in true }
            route("SPAM/HAM") { _ in false }
            route(":keyword") { _ in true }
            route("foo/:keyword") { _ in true }
        }
        XCTAssertTrue(router.responds(to: URL(string: "https://example.com/static")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://example.com/foo")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://example.com/foo/bar")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://example.com/foo/10000")!))
        XCTAssertFalse(router.responds(to: URL(string: "nothttps://example.com/aaa/bbb")!))
        XCTAssertFalse(router.responds(to: URL(string: "https://example.com/spam/ham")!))
        XCTAssertFalse(router.responds(to: URL(string: "static")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo/bar")!))
        XCTAssertFalse(router.responds(to: URL(string: "foo/10000")!))
        XCTAssertFalse(router.responds(to: URL(string: "aaa/bbb")!))
        XCTAssertFalse(router.responds(to: URL(string: "spam/ham")!))
    }

    func testHandle() throws {
        let expectation = self.expectation(description: "Should called handler four times")
        expectation.expectedFulfillmentCount = 4

        let router = try SimpleRouter(accepts: [scheme]) { route in
            route("foobar://static") { context in
                XCTAssertEqual(context.url, URL(string: "foobar://static")!)
                expectation.fulfill()
                return true
            }
            route("foobar://foo/bar") { context in
                XCTAssertEqual(context.parameter(for: "param0"), 123)
                XCTAssertEqual(context.url, URL(string: "foobar://foo/bar?param0=123")!)
                expectation.fulfill()
                return true
            }
            route("foobar://:pokemonName") { context in
                XCTAssertEqual(context.url, URL(string: "foobar://hoge")!)
                XCTAssertEqual(try? context.argument(for: "pokemonName"), "hoge")
                expectation.fulfill()
                return true
            }
            route("foobar://foo/:pokemonName/:keyword2") { context in
                XCTAssertEqual(context.url, URL(string: "foobar://foo/hoge/fuga")!)
                XCTAssertEqual(try? context.argument(for: "pokemonName"), "hoge")
                XCTAssertEqual(try? context.argument(for: "keyword2"), "fuga")
                expectation.fulfill()
                return true
            }
        }
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

    func testHandleWithURLPrefix() throws {
        let expectation = self.expectation(description: "Should called handler four times")
        expectation.expectedFulfillmentCount = 4
        let router = try SimpleRouter(accepts: [.universalLink(URL(string: "https://example.com")!)]) { route in
            route("https://example.com/static") { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/static")!)
                expectation.fulfill()
                return true
            }
            route("https://example.com/foo/bar") { context in
                XCTAssertEqual(context.parameter(for: "param0"), 123)
                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/bar?param0=123")!)
                expectation.fulfill()
                return true
            }
            route("https://example.com/:pokemonName") { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/hoge")!)
                XCTAssertEqual(try? context.argument(for: "pokemonName"), "hoge")
                expectation.fulfill()
                return true
            }
            route("https://example.com/foo/:pokemonName/:keyword2") { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/hoge/fuga")!)
                XCTAssertEqual(try? context.argument(for: "pokemonName"), "hoge")
                XCTAssertEqual(try? context.argument(for: "keyword2"), "fuga")
                expectation.fulfill()
                return true
            }
        }
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

    func testHandleWithoutPrefix() throws {
        let expectation = self.expectation(description: "Should called handler four times")
        expectation.expectedFulfillmentCount = 4

        let router = try SimpleRouter(accepts: [scheme]) { route in
            route("static") { context in
                XCTAssertEqual(context.url, URL(string: "foobar://static")!)
                expectation.fulfill()
                return true
            }
            route("foo/bar") { context in
                XCTAssertEqual(context.parameter(for: "param0"), 123)
                XCTAssertEqual(context.url, URL(string: "foobar://foo/bar?param0=123")!)
                expectation.fulfill()
                return true
            }
            route(":pokemonName") { context in
                XCTAssertEqual(context.url, URL(string: "FOOBAR://HOGE")!)
                XCTAssertEqual(try? context.argument(for: "pokemonName"), "HOGE")
                expectation.fulfill()
                return true
            }
            route("foo/:pokemonName/:keyword2") { context in
                XCTAssertEqual(context.url, URL(string: "foobar://foo/hoge/fuga")!)
                XCTAssertEqual(try? context.argument(for: "pokemonName"), "hoge")
                XCTAssertEqual(try? context.argument(for: "keyword2"), "fuga")
                expectation.fulfill()
                return true
            }
        }
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

    func testHandleWithSlashPrefix() throws {
        let expectation = self.expectation(description: "Should called handler four times")
        expectation.expectedFulfillmentCount = 4

        let router = try SimpleRouter(accepts: [scheme]) { route in
            route("/static") { context in
                XCTAssertEqual(context.url, URL(string: "foobar://static")!)
                expectation.fulfill()
                return true
            }
            route("/foo/bar") { context in
                XCTAssertEqual(context.parameter(for: "param0"), 123)
                XCTAssertEqual(context.url, URL(string: "foobar://foo/bar?param0=123")!)
                expectation.fulfill()
                return true
            }
            route("/:pokemonName") { context in
                XCTAssertEqual(context.url, URL(string: "FOOBAR://HOGE")!)
                XCTAssertEqual(try? context.argument(for: "pokemonName"), "HOGE")
                expectation.fulfill()
                return true
            }
            route("/foo/:pokemonName/:keyword2") { context in
                XCTAssertEqual(context.url, URL(string: "foobar://foo/hoge/fuga")!)
                XCTAssertEqual(try? context.argument(for: "pokemonName"), "hoge")
                XCTAssertEqual(try? context.argument(for: "keyword2"), "fuga")
                expectation.fulfill()
                return true
            }
        }
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

    func testHandleWithoutPrefixWithURLPrefix() throws {
        let expectation = self.expectation(description: "Should called handler four times")
        expectation.expectedFulfillmentCount = 4

        let router = try SimpleRouter(accepts: [.universalLink(URL(string: "https://example.com")!)]) { route in
            route("static") { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/static")!)
                expectation.fulfill()
                return true
            }
            route("foo/bar") { context in
                XCTAssertEqual(context.parameter(for: "param0"), 123)
                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/bar?param0=123")!)
                expectation.fulfill()
                return true
            }
            route(":pokemonName") { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/HOGE")!)
                XCTAssertEqual(try? context.argument(for: "pokemonName"), "HOGE")
                expectation.fulfill()
                return true
            }
            route("foo/:pokemonName/:keyword2") { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/hoge/fuga")!)
                XCTAssertEqual(try? context.argument(for: "pokemonName"), "hoge")
                XCTAssertEqual(try? context.argument(for: "keyword2"), "fuga")
                expectation.fulfill()
                return true
            }
        }
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

    func testHandlerWithSamePatterns() throws {
        let idExpectation = self.expectation(description: "Should called handler with ID")
        let keywordExpectation = self.expectation(description: "Should called handler with keyword")

        let router = try SimpleRouter(accepts: [scheme]) { route in
            route("foobar://foo/:id") { context in
                guard let id: Int = try? context.argument(for: "id") else {
                    return false
                }
                XCTAssertEqual(context.url, URL(string: "foobar://foo/42")!)
                XCTAssertEqual(id, 42)
                idExpectation.fulfill()
                return true
            }
            route("foobar://foo/:pokemonName") { context in
                let pokemonName: String = try! context.argument(for: "pokemonName")
                XCTAssertEqual(context.url, URL(string: "FOOBAR://FOO/BAR")!)
                XCTAssertEqual(pokemonName, "BAR")
                keywordExpectation.fulfill()
                return true
            }
        }
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/42")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "FOOBAR://FOO/BAR")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/42")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/bar")!))
        wait(for: [idExpectation, keywordExpectation], timeout: 2.0)
    }

    func testHandlerWithSamePatternsWithURLPrefix() throws {
        let idExpectation = self.expectation(description: "Should called handler with ID")
        let keywordExpectation = self.expectation(description: "Should called handler with keyword")

        let router = try SimpleRouter(accepts: [.universalLink(URL(string: "https://example.com")!)]) { route in
            route("https://example.com/foo/:id") { context in
                guard let id: Int = try? context.argument(for: "id") else {
                    return false
                }
                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/42")!)
                XCTAssertEqual(id, 42)
                idExpectation.fulfill()
                return true
            }
            route("https://example.com/foo/:pokemonName") { context in
                let pokemonName: String = try! context.argument(for: "pokemonName")
                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/bar")!)
                XCTAssertEqual(pokemonName, "bar")
                keywordExpectation.fulfill()
                return true
            }
        }
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/foo/42")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/foo/bar")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/42")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/bar")!))
        wait(for: [idExpectation, keywordExpectation], timeout: 2.0)
    }

    func testHandlerWithSamePatternsWithoutPrefix() throws {
        let idExpectation = self.expectation(description: "Should called handler with ID")
        let keywordExpectation = self.expectation(description: "Should called handler with keyword")

        let router = try SimpleRouter(accepts: [scheme]) { route in
            route("foo/:id") { context in
                guard let id: Int = try? context.argument(for: "id") else {
                    return false
                }
                XCTAssertEqual(context.url, URL(string: "foobar://foo/42")!)
                XCTAssertEqual(id, 42)
                idExpectation.fulfill()
                return true
            }
            route("foo/:pokemonName") { context in
                let pokemonName: String = try! context.argument(for: "pokemonName")
                XCTAssertEqual(context.url, URL(string: "FOOBAR://FOO/BAR")!)
                XCTAssertEqual(pokemonName, "BAR")
                keywordExpectation.fulfill()
                return true
            }
        }
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/42")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "FOOBAR://FOO/BAR")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/42")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/bar")!))
        wait(for: [idExpectation, keywordExpectation], timeout: 2.0)
    }

    func testHandlerWithSamePatternsWithoutPrefixWithURLPrefix() throws {
        let idExpectation = self.expectation(description: "Should called handler with ID")
        let keywordExpectation = self.expectation(description: "Should called handler with keyword")

        let router = try SimpleRouter(accepts: [.universalLink(URL(string: "https://example.com/")!)]) { route in
            route("foo/:id") { context in
                guard let id: Int = try? context.argument(for: "id") else {
                    return false
                }
                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/42")!)
                XCTAssertEqual(id, 42)
                idExpectation.fulfill()
                return true
            }
            route("foo/:pokemonName") { context in
                let pokemonName: String = try! context.argument(for: "pokemonName")
                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/bar")!)
                XCTAssertEqual(pokemonName, "bar")
                keywordExpectation.fulfill()
                return true
            }
        }
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/foo/42")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/foo/bar")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/42")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/bar")!))
        wait(for: [idExpectation, keywordExpectation], timeout: 2.0)
    }

    func testHandleReturnsFalse() throws {
        let expectation = self.expectation(description: "Should called handler twice")
        expectation.expectedFulfillmentCount = 2

        let router = try SimpleRouter(accepts: [scheme]) { route in
            route("foobar://foo/bar") { _ in
                expectation.fulfill()
                return false
            }
            route("/spam/:matchingKeyword") { context in
                XCTAssertEqual(try? context.argument(for: "matchingKeyword"), "ham")
                expectation.fulfill()
                return true
            }
        }
        XCTAssertFalse(router.openIfPossible(URL(string: "foobar://foo/bar")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://spam/ham")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandleReturnsFalseWithURLPrefix() throws {
        let expectation = self.expectation(description: "Should called handler twice")
        expectation.expectedFulfillmentCount = 2

        let router = try SimpleRouter(accepts: [.universalLink(URL(string: "https://example.com")!)]) { route in
            route("https://example.com/foo/bar") { _ in
                expectation.fulfill()
                return false
            }
            route("/pokemons/:pokemonName") { context in
                XCTAssertEqual(try? context.argument(for: "pokemonName"), "Pikachu")
                expectation.fulfill()
                return true
            }
        }
        XCTAssertFalse(router.openIfPossible(URL(string: "https://example.com/foo/bar")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/pokemons/Pikachu")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandleReturnsFalseWithoutPrefix() throws {
        let expectation = self.expectation(description: "Should called handler twice")
        expectation.expectedFulfillmentCount = 2

            let router = try SimpleRouter(accepts: [scheme]) { route in
            route("foo/bar") { _ in
                expectation.fulfill()
                return false
            }
            route("/pokemons/:pokemonName") { context in
                XCTAssertEqual(try? context.argument(for: "pokemonName"), "Pikachu")
                expectation.fulfill()
                return true
            }
            }
        XCTAssertFalse(router.openIfPossible(URL(string: "foobar://foo/bar")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://pokemons/Pikachu")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandleCapitalCasedHostKeyword() throws {
        let expectation = self.expectation(description: "Should called handler")

        let router = try SimpleRouter(accepts: [scheme]) { route in
            route(":pokemonName") { context in
                XCTAssertEqual(context.url.absoluteString, "FOOBAR://FOO")
                XCTAssertEqual(try! context.argument(for: "pokemonName"), "FOO")
                expectation.fulfill()
                return true
            }
        }
        XCTAssertTrue(router.openIfPossible(URL(string: "FOOBAR://FOO")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandleReturnsFalseWithoutPrefixWithURLPrefix() throws {
        let expectation = self.expectation(description: "Should called handler twice")
        expectation.expectedFulfillmentCount = 2

        let router = try SimpleRouter(accepts: [.universalLink(URL(string: "https://example.com/")!)]) { route in
            route("foo/bar") { _ in
                expectation.fulfill()
                return false
            }
            route("/foo/:pokemonName") { context in
                XCTAssertEqual(try? context.argument(for: "pokemonName"), "bar")
                expectation.fulfill()
                return true
            }
        }
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/foo/bar")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foo/bar")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testWithUserInfo() throws {
        struct UserInfo {
            let value: Int
        }
        var userInfo: UserInfo?
        let router = try Router<UserInfo>(accepts: [scheme]) { route in
            route("foobar://static") { context in
                XCTAssertEqual(context.url, URL(string: "foobar://static")!)
                userInfo = context.userInfo
                return true
            }
        }
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://static")!, userInfo: UserInfo(value: 42)))
        XCTAssertFalse(router.openIfPossible(URL(string: "static")!, userInfo: UserInfo(value: 42)))
        XCTAssertEqual(userInfo?.value, 42)
    }

    func testWithUserInfoWithURLPrefix() throws {
        struct UserInfo {
            let value: Int
        }

        var userInfo: UserInfo?
        let router = try Router<UserInfo>(accepts: [.universalLink(URL(string: "https://example.com")!)]) { route in
            route("https://example.com/static") { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/static")!)
                userInfo = context.userInfo
                return true
            }
        }
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/static")!, userInfo: UserInfo(value: 42)))
        XCTAssertFalse(router.openIfPossible(URL(string: "static")!, userInfo: UserInfo(value: 42)))
        XCTAssertEqual(userInfo?.value, 42)
    }

    func testWithUserInfoWithoutPrefix() throws {
        struct UserInfo {
            let value: Int
        }
        var userInfo: UserInfo?

        let router = try Router<UserInfo>(accepts: [scheme]) { route in
            route("static") { context in
                XCTAssertEqual(context.url, URL(string: "foobar://static")!)
                userInfo = context.userInfo
                return true
            }
        }
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://static")!, userInfo: UserInfo(value: 42)))
        XCTAssertFalse(router.openIfPossible(URL(string: "static")!, userInfo: UserInfo(value: 42)))
        XCTAssertEqual(userInfo?.value, 42)
    }

    func testWithUserInfoWithoutPrefixWithURLPrefix() throws {
        struct UserInfo {
            let value: Int
        }
        var userInfo: UserInfo?
        let router = try Router<UserInfo>(accepts: [.universalLink(URL(string: "https://example.com/")!)]) { route in
            route("static") { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/static")!)
                userInfo = context.userInfo
                return true
            }
        }
        XCTAssertTrue(router.openIfPossible(URL(string: "https://example.com/static")!, userInfo: UserInfo(value: 42)))
        XCTAssertFalse(router.openIfPossible(URL(string: "static")!, userInfo: UserInfo(value: 42)))
        XCTAssertEqual(userInfo?.value, 42)
    }
}
