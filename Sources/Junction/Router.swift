import Foundation

public typealias SimpleRouter = Router<Void>

public final class Router<UserInfo> {
    public let scheme: String
    private var routes: [Route<UserInfo>] = []

    public init(scheme: String) {
        self.scheme = scheme
    }

    internal func register(route: Route<UserInfo>) {
        if scheme != route.patternURL.scheme {
            assertionFailure("Router and pattern must have the same schemes")
        } else {
            routes.append(route)
        }
    }

    public func openIfPossible(_ url: URL, userInfo: UserInfo? = nil) -> Bool {
        if scheme != url.scheme {
            return false
        }
        for route in routes {
            if route.openIfPossible(url, userInfo: userInfo) {
                return true
            }
        }
        return false
    }

    public func canRespond(to url: URL, userInfo: UserInfo? = nil) -> Bool {
        if scheme != url.scheme {
            return false
        }
        for route in routes {
            if route.canRespond(to: url, userInfo: userInfo) {
                return true
            }
        }
        return false
    }

    public func register(routes: [(String, Route<UserInfo>.Handler)]) {
        for (pattern, handler) in routes {
            let route = Route(pattern: pattern, handler: handler)
            register(route: route)
        }
    }
}
