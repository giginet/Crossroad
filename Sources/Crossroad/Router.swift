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

public extension Router where UserInfo == Void {
    @discardableResult
    func openIfPossible(_ url: URL) -> Bool {
        return openIfPossible(url, userInfo: ())
    }

    func responds(to url: URL) -> Bool {
        return responds(to: url, userInfo: ())
    }
}
