import Foundation

public typealias SimpleRouter = Router<Void>

public final class Router<UserInfo> {
    private let scheme: String
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
    public func openIfPossible(_ url: URL, userInfo: UserInfo) -> Bool {
        if scheme != url.scheme {
            return false
        }
        return routes.first { $0.openIfPossible(url, userInfo: userInfo) } != nil
    }

    public func responds(to url: URL, userInfo: UserInfo) -> Bool {
        if scheme != url.scheme {
            return false
        }
        return routes.first { $0.responds(to: url, userInfo: userInfo) } != nil
    }

    public func register(_ routes: [(String, Route<UserInfo>.Handler)]) {
        for (pattern, handler) in routes {
            let patternURLString: String
            if pattern.hasPrefix("\(scheme)://") {
                patternURLString = pattern
            } else {
                patternURLString = "\(scheme)://\(pattern)"
            }
            guard let patternURL = PatternURL(string: patternURLString) else {
                assertionFailure("\(pattern) is invalid")
                continue
            }
            let route = Route(pattern: patternURL, handler: handler)
            register(route)
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
