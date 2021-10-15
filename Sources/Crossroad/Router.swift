import Foundation
import UIKit

public typealias SimpleRouter = Router<Void>

public final class Router<UserInfo> {
    let linkSources: Set<LinkSource>
    var routes: [Route] = []
    private let parser = Parser()

    init(linkSources: Set<LinkSource>, routes: [Route]) {
        self.linkSources = linkSources
        self.routes = routes
    }

    func register(_ route: Route) {
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

    private func expandAcceptablePattern(of route: Route) -> Set<Pattern> {
        return []
    }

    private struct MatchResult<UserInfo> {
        let route: Route
        let context: Context<UserInfo>
    }
    private func searchMatchingRoutes(to url: URL, userInfo: UserInfo) -> [MatchResult<UserInfo>] {
        routes.reduce(into: []) { matchings, route in
            for pattern in expandAcceptablePattern(of: route) {
                if let context = parser.parse(url, in: pattern) {
                    let result = MatchResult(route: route, context: context.attached(userInfo))
                    matchings.append(result)
                }
            }
        }
    }
}

public extension Router where UserInfo == Void {
    @discardableResult
    func openIfPossible(_ url: URL) -> Bool {
        return openIfPossible(url, userInfo: ())
    }

    func responds(to url: URL) -> Bool {
        return responds(to: url, userInfo: ())
    }
}
