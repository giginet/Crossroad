import Foundation

public typealias SimpleRouter = Router<Void>

public final class Router<UserInfo> {
    public let scheme: String
    private var routes: [Route<UserInfo>] = []

    public init(scheme: String) {
        self.scheme = scheme
    }

    internal func register(_ route: Route<UserInfo>) {
        if scheme != route.patternURL.scheme {
            assertionFailure("Router and pattern must have the same schemes. expect: \(scheme), actual: \(route.patternURL.scheme)")
        } else {
            routes.append(route)
        }
    }

    @discardableResult
    public func openIfPossible(_ url: URL, userInfo: UserInfo? = nil) -> Bool {
        if scheme != url.scheme {
            return false
        }
        return routes.first { $0.openIfPossible(url, userInfo: userInfo) } != nil
    }

    public func responds(to url: URL, userInfo: UserInfo? = nil) -> Bool {
        if scheme != url.scheme {
            return false
        }
        return routes.first { $0.responds(to: url, userInfo: userInfo) } != nil
    }

    public func register(_ routes: [(String, Route<UserInfo>.Handler)]) {
        for (pattern, handler) in routes {
            guard let patternURL = PatternURL(string: pattern) else {
                assertionFailure("\(pattern) is invalid")
                continue
            }
            let route = Route(pattern: patternURL, handler: handler)
            register(route)
        }
    }
}
