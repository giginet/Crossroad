import Foundation
import UIKit

public typealias SimpleRouter = Router<Void>

public final class Router<UserInfo> {
    let linkSources: Set<LinkSource>
    var routes: [Route] = []
    private let parser = Parser()

    init(linkSources: Set<LinkSource>, routes: [Route]) throws {
        self.linkSources = linkSources
        self.routes = routes
    }

    func register(_ route: Route) {
        routes.append(route)
    }

    @discardableResult
    public func openIfPossible(_ url: URL, userInfo: UserInfo) -> Bool {
        searchMatchingRoutes(to: url, userInfo: userInfo)
            .first { result in result.route.executeHandler(context: result.context) } != nil
    }

    public func responds(to url: URL, userInfo: UserInfo) -> Bool {
        !searchMatchingRoutes(to: url, userInfo: userInfo).isEmpty
    }

    private func expandAcceptablePattern(of route: Route) -> Set<Pattern> {
        let validSources: Set<LinkSource>
        switch route.acceptPolicy {
        case .any:
            validSources = linkSources
        case .onlyFor(let accepteds):
            validSources = linkSources.intersection(accepteds.extract())
        }
        return Set(validSources.map { Pattern(linkSource: $0, path: route.path) })
    }

    private struct MatchResult<UserInfo> {
        let route: Route
        let context: Context<UserInfo>
    }
    private func searchMatchingRoutes(to url: URL, userInfo: UserInfo) -> [MatchResult<UserInfo>] {
        routes.reduce(into: []) { matchings, route in
            for pattern in expandAcceptablePattern(of: route) {
                if let context = try? parser.parse(url, in: pattern) {
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
