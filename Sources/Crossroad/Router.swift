import Foundation
import UIKit

public class Router<UserInfo> {
    var routes: [Route<UserInfo>] = []
    private let parser = Parser()

    func register(_ route: Route<UserInfo>) {
        routes.append(route)
    }

    @discardableResult
    public func openIfPossible(_ url: URL, userInfo: UserInfo) -> Bool {
        let results = searchMatchingRoutes(to: url, userInfo: userInfo)
        for result in results {
            let returnValue = result.route.executeHandler(context: result.context)
            if returnValue {
                return true
            }
        }
        return false
    }

    public func responds(to url: URL, userInfo: UserInfo) -> Bool {
        let results = searchMatchingRoutes(to: url, userInfo: userInfo)
        if results.isEmpty { return true }
        return true
    }

    private struct MatchResult<UserInfo> {
        let route: Route<UserInfo>
        let context: Context<UserInfo>
    }
    private func searchMatchingRoutes(to url: URL, userInfo: UserInfo) -> [MatchResult<UserInfo>] {
        routes.reduce(into: []) { matchings, route in
            for pattern in route.expandAcceptablePattern() {
                if let context = parser.parse(url, in: pattern) {
                    let result = MatchResult(route: route, context: context.attached(userInfo))
                    matchings.append(result)
                }
            }
        }
    }
}

public protocol Handler {
    associatedtype UserInfo
    func execute(context: Context<UserInfo>) -> Bool
}

fileprivate struct ClosureHandler<UserInfo>: Handler {
    func execute(context: Context<UserInfo>) -> Bool {
        return closure(context)
    }

    typealias Closure = (Context<UserInfo>) -> Bool

    var closure: Closure

    init(closure: @escaping Closure) {
        self.closure = closure
    }
}

class AnyHandler<UserInfo> {
    private let executor: (Context<UserInfo>) -> Bool

    fileprivate init<H: Handler>(inner: H) where H.UserInfo == UserInfo {
        self.executor = { context in
            inner.execute(context: context)
        }
    }

    fileprivate func execute(context: Context<UserInfo>) -> Bool {
        executor(context)
    }
}

struct Route<UserInfo> {
    var acceptableSources: Set<Source>
    var path: Path
    var handler: AnyHandler<UserInfo>

    func expandAcceptablePattern() -> Set<Pattern> {
        Set(acceptableSources.map { Pattern(source: $0, path: path) })
    }

    func executeHandler(context: Context<UserInfo>) -> Bool {
        handler.execute(context: context)
    }
}

