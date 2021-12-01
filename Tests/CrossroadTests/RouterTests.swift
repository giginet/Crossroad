import XCTest
import Crossroad

final class RouterTest: XCTestCase {
    enum TestingError: Swift.Error {
        case somethingWrong
    }

    private let scheme: LinkSource = .customURLScheme("foobar")

    func testCanRespond() throws {
        let router = try SimpleRouter(accepting: [scheme]) { registry in
            registry.route("foobar://static") { _ in }
            registry.route("foobar://foo/bar") { _ in }
            registry.route("foobar://SPAM/HAM") { _ in throw TestingError.somethingWrong }
            registry.route("foobar://:keyword") { _ in }
            registry.route("foobar://foo/:keyword") { _ in }
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

    func testCanRespondWithNoPathComponents() throws {
        let router = try SimpleRouter(accepting: [scheme, .universalLink(URL(string: "https://example.com")!)]) { registry in
            registry.route("/") { _ in }
        }
        XCTAssertTrue(router.responds(to: URL(string: "foobar://")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://example.com")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://example.com/")!))
        XCTAssertFalse(router.responds(to: URL(string: "http://example.com/")!))
    }

    func testCanRespondWithCapitalCase() throws {
        let router = try SimpleRouter(accepting: [.customURLScheme("FOOBAR")]) { registry in
            registry.route("FOOBAR://STATIC") { _ in }
            registry.route("FOOBAR://FOO/BAR") { _ in }
            registry.route("FOOBAR://SPAM/HAM") { _ in throw TestingError.somethingWrong }
            registry.route("FOOBAR://:keyword") { _ in }
            registry.route("FOOBAR://FOO/:keyword") { _ in }
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
        let router = try SimpleRouter(accepting: [.universalLink(URL(string: "https://example.com")!)]) { registry in
            registry.route("https://example.com/static") { _ in }
            registry.route("https://example.com/foo/bar") { _ in }
            registry.route("https://example.com/SPAM/HAM") { _ in throw TestingError.somethingWrong }
            registry.route("https://example.com/:keyword") { _ in }
            registry.route("https://example.com/foo/:keyword") { _ in }
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
        let router = try SimpleRouter(accepting: [scheme]) { registry in
            registry.route("static") { _ in }
            registry.route("foo/bar") { _ in }
            registry.route("SPAM/HAM") { _ in throw TestingError.somethingWrong }
            registry.route(":keyword") { _ in }
            registry.route("foo/:keyword") { _ in }
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
        let router = try SimpleRouter(accepting: [scheme]) { registry in
            registry.route("/static") { _ in }
            registry.route("/foo/bar") { _ in }
            registry.route("/SPAM/HAM") { _ in throw TestingError.somethingWrong }
            registry.route("/:keyword") { _ in }
            registry.route("/foo/:keyword") { _ in }
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
        let router = try SimpleRouter(accepting: [.universalLink(URL(string: "https://example.com")!)]) { registry in
            registry.route("static") { _ in }
            registry.route("foo/bar") { _ in }
            registry.route("SPAM/HAM") { _ in throw TestingError.somethingWrong }
            registry.route(":keyword") { _ in }
            registry.route("foo/:keyword") { _ in }
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

    func testHandle() async throws {
        let expectation = self.expectation(description: "Should called handler four times")
        expectation.expectedFulfillmentCount = 4

        let router = try SimpleRouter(accepting: [scheme]) { registry in
            registry.route("foobar://static") { context in
                XCTAssertEqual(context.url, URL(string: "foobar://static")!)
                expectation.fulfill()
            }
            registry.route("foobar://foo/bar") { context in
                XCTAssertEqual(context.queryParameter(named: "param0"), 123)
                XCTAssertEqual(context.url, URL(string: "foobar://foo/bar?param0=123")!)
                expectation.fulfill()
            }
            registry.route("foobar://:pokemonName") { context in
                XCTAssertEqual(context.url, URL(string: "foobar://hoge")!)
                XCTAssertEqual(try? context.argument(named: "pokemonName"), "hoge")
                expectation.fulfill()
            }
            registry.route("foobar://foo/:pokemonName/:keyword2") { context in
                XCTAssertEqual(context.url, URL(string: "foobar://foo/hoge/fuga")!)
                XCTAssertEqual(try? context.argument(named: "pokemonName"), "hoge")
                XCTAssertEqual(try? context.argument(named: "keyword2"), "fuga")
                expectation.fulfill()
            }
        }
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "foobar://static")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "foobar://foo/bar?param0=123")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "foobar://hoge")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "foobar://foo/hoge/fuga")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foobar://spam/ham")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "notfoobar://static")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "static")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foo/bar?param0=123")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "hoge")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foo/hoge/fuga")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "spam/ham")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandleWithURLPrefix() async throws {
        let expectation = self.expectation(description: "Should called handler four times")
        expectation.expectedFulfillmentCount = 4
        let router = try SimpleRouter(accepting: [.universalLink(URL(string: "https://example.com")!)]) { registry in
            registry.route("https://example.com/static") { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/static")!)
                expectation.fulfill()
            }
            registry.route("https://example.com/foo/bar") { context in
                XCTAssertEqual(context.queryParameter(named: "param0"), 123)
                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/bar?param0=123")!)
                expectation.fulfill()
            }
            registry.route("https://example.com/:pokemonName") { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/hoge")!)
                XCTAssertEqual(try? context.argument(named: "pokemonName"), "hoge")
                expectation.fulfill()
            }
            registry.route("https://example.com/foo/:pokemonName/:keyword2") { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/hoge/fuga")!)
                XCTAssertEqual(try? context.argument(named: "pokemonName"), "hoge")
                XCTAssertEqual(try? context.argument(named: "keyword2"), "fuga")
                expectation.fulfill()
            }
        }
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "https://example.com/static")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "https://example.com/foo/bar?param0=123")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "https://example.com/hoge")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "https://example.com/foo/hoge/fuga")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "https://example.com/spam/ham")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "nothttps://example.com/static")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "static")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foo/bar?param0=123")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "hoge")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foo/hoge/fuga")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "spam/ham")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandleWithoutPrefix() async throws {
        let expectation = self.expectation(description: "Should called handler four times")
        expectation.expectedFulfillmentCount = 4

        let router = try SimpleRouter(accepting: [scheme]) { registry in
            registry.route("static") { context in
                XCTAssertEqual(context.url, URL(string: "foobar://static")!)
                expectation.fulfill()
            }
            registry.route("foo/bar") { context in
                XCTAssertEqual(context.queryParameter(named: "param0"), 123)
                XCTAssertEqual(context.url, URL(string: "foobar://foo/bar?param0=123")!)
                expectation.fulfill()
            }
            registry.route(":pokemonName") { context in
                XCTAssertEqual(context.url, URL(string: "FOOBAR://HOGE")!)
                XCTAssertEqual(try? context.argument(named: "pokemonName"), "HOGE")
                expectation.fulfill()
            }
            registry.route("foo/:pokemonName/:keyword2") { context in
                XCTAssertEqual(context.url, URL(string: "foobar://foo/hoge/fuga")!)
                XCTAssertEqual(try? context.argument(named: "pokemonName"), "hoge")
                XCTAssertEqual(try? context.argument(named: "keyword2"), "fuga")
                expectation.fulfill()
            }
        }
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "foobar://static")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "foobar://foo/bar?param0=123")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "FOOBAR://HOGE")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "foobar://foo/hoge/fuga")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foobar://spam/ham")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "notfoobar://static")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "static")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foo/bar?param0=123")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "hoge")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foo/hoge/fuga")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "spam/ham")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandleWithSlashPrefix() async throws {
        let expectation = self.expectation(description: "Should called handler four times")
        expectation.expectedFulfillmentCount = 4

        let router = try SimpleRouter(accepting: [scheme]) { registry in
            registry.route("/static") { context in
                XCTAssertEqual(context.url, URL(string: "foobar://static")!)
                expectation.fulfill()
            }
            registry.route("/foo/bar") { context in
                XCTAssertEqual(context.queryParameter(named: "param0"), 123)
                XCTAssertEqual(context.url, URL(string: "foobar://foo/bar?param0=123")!)
                expectation.fulfill()
            }
            registry.route("/:pokemonName") { context in
                XCTAssertEqual(context.url, URL(string: "FOOBAR://HOGE")!)
                XCTAssertEqual(try? context.argument(named: "pokemonName"), "HOGE")
                expectation.fulfill()
            }
            registry.route("/foo/:pokemonName/:keyword2") { context in
                XCTAssertEqual(context.url, URL(string: "foobar://foo/hoge/fuga")!)
                XCTAssertEqual(try? context.argument(named: "pokemonName"), "hoge")
                XCTAssertEqual(try? context.argument(named: "keyword2"), "fuga")
                expectation.fulfill()
            }
        }
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "foobar://static")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "foobar://foo/bar?param0=123")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "FOOBAR://HOGE")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "foobar://foo/hoge/fuga")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foobar://spam/ham")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "notfoobar://static")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "static")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foo/bar?param0=123")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "hoge")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foo/hoge/fuga")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "spam/ham")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandleWithoutPrefixWithURLPrefix() async throws {
        let expectation = self.expectation(description: "Should called handler four times")
        expectation.expectedFulfillmentCount = 4

        let router = try SimpleRouter(accepting: [.universalLink(URL(string: "https://example.com")!)]) { registry in
            registry.route("static") { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/static")!)
                expectation.fulfill()
            }
            registry.route("foo/bar") { context in
                XCTAssertEqual(context.queryParameter(named: "param0"), 123)
                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/bar?param0=123")!)
                expectation.fulfill()
            }
            registry.route(":pokemonName") { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/HOGE")!)
                XCTAssertEqual(try? context.argument(named: "pokemonName"), "HOGE")
                expectation.fulfill()
            }
            registry.route("foo/:pokemonName/:keyword2") { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/hoge/fuga")!)
                XCTAssertEqual(try? context.argument(named: "pokemonName"), "hoge")
                XCTAssertEqual(try? context.argument(named: "keyword2"), "fuga")
                expectation.fulfill()
            }
        }
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "https://example.com/static")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "https://example.com/foo/bar?param0=123")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "https://example.com/HOGE")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "https://example.com/foo/hoge/fuga")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "https://example.com/spam/ham")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "nothttps://example.com/static")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "static")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foo/bar?param0=123")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "hoge")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foo/hoge/fuga")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "spam/ham")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandlerWithSamePatterns() async throws {
        let idExpectation = self.expectation(description: "Should called handler with ID")
        let keywordExpectation = self.expectation(description: "Should called handler with keyword")

        let router = try SimpleRouter(accepting: [scheme]) { registry in
            registry.route("foobar://foo/:id") { context in
                let id: Int = try context.argument(named: "id")
                XCTAssertEqual(context.url, URL(string: "foobar://foo/42")!)
                XCTAssertEqual(id, 42)
                idExpectation.fulfill()
            }
            registry.route("foobar://foo/:pokemonName") { context in
                let pokemonName: String = try! context.argument(named: "pokemonName")
                XCTAssertEqual(context.url, URL(string: "FOOBAR://FOO/BAR")!)
                XCTAssertEqual(pokemonName, "BAR")
                keywordExpectation.fulfill()
            }
        }
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "foobar://foo/42")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "FOOBAR://FOO/BAR")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foo/42")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foo/bar")!))
        wait(for: [idExpectation, keywordExpectation], timeout: 2.0)
    }

    func testHandlerWithSamePatternsWithURLPrefix() async throws {
        let idExpectation = self.expectation(description: "Should called handler with ID")
        let keywordExpectation = self.expectation(description: "Should called handler with keyword")

        let router = try SimpleRouter(accepting: [.universalLink(URL(string: "https://example.com")!)]) { registry in
            registry.route("https://example.com/foo/:id") { context in
                let id: Int = try context.argument(named: "id")
                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/42")!)
                XCTAssertEqual(id, 42)
                idExpectation.fulfill()
            }
            registry.route("https://example.com/foo/:pokemonName") { context in
                let pokemonName: String = try! context.argument(named: "pokemonName")
                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/bar")!)
                XCTAssertEqual(pokemonName, "bar")
                keywordExpectation.fulfill()
            }
        }
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "https://example.com/foo/42")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "https://example.com/foo/bar")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foo/42")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foo/bar")!))
        wait(for: [idExpectation, keywordExpectation], timeout: 2.0)
    }

    func testHandlerWithSamePatternsWithoutPrefix() async throws {
        let idExpectation = self.expectation(description: "Should called handler with ID")
        let keywordExpectation = self.expectation(description: "Should called handler with keyword")

        let router = try SimpleRouter(accepting: [scheme]) { registry in
            registry.route("foo/:id") { context in
                let id: Int = try context.argument(named: "id")
                XCTAssertEqual(context.url, URL(string: "foobar://foo/42")!)
                XCTAssertEqual(id, 42)
                idExpectation.fulfill()
            }
            registry.route("foo/:pokemonName") { context in
                let pokemonName: String = try! context.argument(named: "pokemonName")
                XCTAssertEqual(context.url, URL(string: "FOOBAR://FOO/BAR")!)
                XCTAssertEqual(pokemonName, "BAR")
                keywordExpectation.fulfill()
            }
        }
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "foobar://foo/42")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "FOOBAR://FOO/BAR")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foo/42")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foo/bar")!))
        wait(for: [idExpectation, keywordExpectation], timeout: 2.0)
    }

    func testHandlerWithSamePatternsWithoutPrefixWithURLPrefix() async throws {
        let idExpectation = self.expectation(description: "Should called handler with ID")
        let keywordExpectation = self.expectation(description: "Should called handler with keyword")

        let router = try SimpleRouter(accepting: [.universalLink(URL(string: "https://example.com")!)]) { registry in
            registry.route("foo/:id") { context in
                let id: Int = try context.argument(named: "id")

                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/42")!)
                XCTAssertEqual(id, 42)
                idExpectation.fulfill()
            }
            registry.route("foo/:pokemonName") { context in
                let pokemonName: String = try! context.argument(named: "pokemonName")
                XCTAssertEqual(context.url, URL(string: "https://example.com/foo/bar")!)
                XCTAssertEqual(pokemonName, "bar")
                keywordExpectation.fulfill()
            }
        }
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "https://example.com/foo/42")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "https://example.com/foo/bar")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foo/42")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foo/bar")!))
        wait(for: [idExpectation, keywordExpectation], timeout: 2.0)
    }

    func testHandleReturnsFalse() async throws {
        let expectation = self.expectation(description: "Should called handler twice")
        expectation.expectedFulfillmentCount = 2

        let router = try SimpleRouter(accepting: [scheme]) { registry in
            registry.route("foobar://foo/bar") { _ in
                expectation.fulfill()
                throw TestingError.somethingWrong
            }
            registry.route("/spam/:matchingKeyword") { context in
                XCTAssertEqual(try? context.argument(named: "matchingKeyword"), "ham")
                expectation.fulfill()
            }
        }
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foobar://foo/bar")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "foobar://spam/ham")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandleReturnsFalseWithURLPrefix() async throws {
        let expectation = self.expectation(description: "Should called handler twice")
        expectation.expectedFulfillmentCount = 2

        let router = try SimpleRouter(accepting: [.universalLink(URL(string: "https://example.com")!)]) { registry in
            registry.route("https://example.com/foo/bar") { _ in
                expectation.fulfill()
                throw TestingError.somethingWrong
            }
            registry.route("/pokemons/:pokemonName") { context in
                XCTAssertEqual(try? context.argument(named: "pokemonName"), "Pikachu")
                expectation.fulfill()
            }
        }
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "https://example.com/foo/bar")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "https://example.com/pokemons/Pikachu")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandleReturnsFalseWithoutPrefix() async throws {
        let expectation = self.expectation(description: "Should called handler twice")
        expectation.expectedFulfillmentCount = 2

            let router = try SimpleRouter(accepting: [scheme]) { registry in
            registry.route("foo/bar") { _ in
                expectation.fulfill()
                throw TestingError.somethingWrong
            }
            registry.route("/pokemons/:pokemonName") { context in
                XCTAssertEqual(try? context.argument(named: "pokemonName"), "Pikachu")
                expectation.fulfill()
            }
            }
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foobar://foo/bar")!))
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "foobar://pokemons/Pikachu")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandleCapitalCasedHostKeyword() async throws {
        let expectation = self.expectation(description: "Should called handler")

        let router = try SimpleRouter(accepting: [scheme]) { registry in
            registry.route(":pokemonName") { context in
                XCTAssertEqual(context.url.absoluteString, "FOOBAR://FOO")
                XCTAssertEqual(try! context.argument(named: "pokemonName"), "FOO")
                expectation.fulfill()
            }
        }
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "FOOBAR://FOO")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testHandleReturnsFalseWithoutPrefixWithURLPrefix() async throws {
        let expectation = self.expectation(description: "Should called handler twice")
        expectation.expectedFulfillmentCount = 2

        let router = try SimpleRouter(accepting: [.universalLink(URL(string: "https://example.com")!)]) { registry in
            registry.route("foo/bar") { _ in
                expectation.fulfill()
                throw TestingError.somethingWrong
            }
            registry.route("/foo/:pokemonName") { context in
                XCTAssertEqual(try? context.argument(named: "pokemonName"), "bar")
                expectation.fulfill()
            }
        }
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "https://example.com/foo/bar")!))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "foo/bar")!))
        wait(for: [expectation], timeout: 2.0)
    }

    func testWithUserInfo() async throws {
        struct UserInfo {
            let value: Int
        }
        var userInfo: UserInfo?
        let router = try Router<UserInfo>(accepting: [scheme]) { registry in
            registry.route("foobar://static") { context in
                XCTAssertEqual(context.url, URL(string: "foobar://static")!)
                userInfo = context.userInfo
            }
        }
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "foobar://static")!, userInfo: UserInfo(value: 42)))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "static")!, userInfo: UserInfo(value: 42)))
        XCTAssertEqual(userInfo?.value, 42)
    }

    func testWithUserInfoWithURLPrefix() async throws {
        struct UserInfo {
            let value: Int
        }

        var userInfo: UserInfo?
        let router = try Router<UserInfo>(accepting: [.universalLink(URL(string: "https://example.com")!)]) { registry in
            registry.route("https://example.com/static") { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/static")!)
                userInfo = context.userInfo
            }
        }
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "https://example.com/static")!, userInfo: UserInfo(value: 42)))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "static")!, userInfo: UserInfo(value: 42)))
        XCTAssertEqual(userInfo?.value, 42)
    }

    func testWithUserInfoWithoutPrefix() async throws {
        struct UserInfo {
            let value: Int
        }
        var userInfo: UserInfo?

        let router = try Router<UserInfo>(accepting: [scheme]) { registry in
            registry.route("static") { context in
                XCTAssertEqual(context.url, URL(string: "foobar://static")!)
                userInfo = context.userInfo
            }
        }
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "foobar://static")!, userInfo: UserInfo(value: 42)))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "static")!, userInfo: UserInfo(value: 42)))
        XCTAssertEqual(userInfo?.value, 42)
    }

    func testWithUserInfoWithoutPrefixWithURLPrefix() async throws {
        struct UserInfo {
            let value: Int
        }
        var userInfo: UserInfo?
        let router = try Router<UserInfo>(accepting: [.universalLink(URL(string: "https://example.com")!)]) { registry in
            registry.route("static") { context in
                XCTAssertEqual(context.url, URL(string: "https://example.com/static")!)
                userInfo = context.userInfo
            }
        }
        await assertTrueAsynchronously(await router.openIfPossible(URL(string: "https://example.com/static")!, userInfo: UserInfo(value: 42)))
        await assertFalseAsynchronously(await router.openIfPossible(URL(string: "static")!, userInfo: UserInfo(value: 42)))
        XCTAssertEqual(userInfo?.value, 42)
    }
}
