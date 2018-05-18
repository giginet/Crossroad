import Foundation

public final class Router {
    public let scheme: String
    private var routes: [Route] = []

    public init(scheme: String) {
        self.scheme = scheme
    }

    internal func register(route: Route) {
        if scheme != route.patternURL.scheme {
            assertionFailure("Router and pattern must have the same schemes")
        } else {
            routes.append(route)
        }
    }

    public func openIfPossible(_ url: URL) -> Bool {
        if scheme != url.scheme {
            return false
        }
        for route in routes {
            if route.openIfPossible(url) {
                return true
            }
        }
        return false
    }

    public func canRespond(to url: URL) -> Bool {
        if scheme != url.scheme {
            return false
        }
        for route in routes {
            if route.canRespond(to: url) {
                return true
            }
        }
        return false
    }

    public func register(routes: [(String, Route.Handler)]) {
        for (pattern, handler) in routes {
            let route = Route(pattern: pattern, handler: handler)
            register(route: route)
        }
    }
}
