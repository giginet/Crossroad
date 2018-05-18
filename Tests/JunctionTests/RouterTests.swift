import Foundation
import XCTest
@testable import Junction

final class RouterTest: XCTestCase {
    func makeRouter() -> Router<Void> {
        return Router(scheme: "foobar")
    }

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

    func testCanRespond() {
        let router = makeRouter()
        router.register(routes: [
            ("foobar://static", { _ in true }),
            ("foobar://foo/bar", { _ in true }),
            ("foobar://spam/ham", { _ in false }),
            ("foobar://:keyword", { _ in true }),
            ("foobar://foo/:keyword", { _ in true }),
            ])
        XCTAssertTrue(router.canRespond(to: URL(string: "foobar://static")!))
        XCTAssertTrue(router.canRespond(to: URL(string: "foobar://foo")!))
        XCTAssertTrue(router.canRespond(to: URL(string: "foobar://foo/bar")!))
        XCTAssertTrue(router.canRespond(to: URL(string: "foobar://foo/10000")!))
        XCTAssertFalse(router.canRespond(to: URL(string: "foobar://aaa/bbb")!))
        XCTAssertFalse(router.canRespond(to: URL(string: "notfoobar://aaa/bbb")!))
        XCTAssertTrue(router.canRespond(to: URL(string: "foobar://spam/ham")!))
    }

    func testHandle() {
        let router = makeRouter()
        router.register(routes: [
            ("foobar://static", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://static")!)
                return true
            }),
            ("foobar://foo/bar", { context in
                XCTAssertEqual(context.parameter(for: "param0"), 123)
                XCTAssertEqual(context.url, URL(string: "foobar://foo/bar?param0=123")!)
                return true
            }),
            ("foobar://:keyword", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://hoge")!)
                XCTAssertEqual(try? context.argument(for: "keyword"), "hoge")
                return true
            }),
            ("foobar://foo/:keyword", { context in
                XCTAssertEqual(context.url, URL(string: "foobar://foo/hoge")!)
                XCTAssertEqual(try? context.argument(for: "keyword"), "hoge")
                return true
            }),
            ])
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://static")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/bar?param0=123")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://hoge")!))
        XCTAssertTrue(router.openIfPossible(URL(string: "foobar://foo/hoge")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "foobar://spam/ham")!))
        XCTAssertFalse(router.openIfPossible(URL(string: "notfoobar://static")!))
    }

    func testHandleReturnsFalse() {
        let router = makeRouter()
        var matchesRoutes = 0
        router.register(routes: [
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
}
