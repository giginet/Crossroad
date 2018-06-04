import Foundation

public typealias SimpleRouter = Router<Void>

public final class Router<UserInfo> {
    private let scheme: String
    private var routes: [Route<UserInfo>] = []

    public init(scheme: String) {
        self.scheme = scheme
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
            var pattern = pattern
            let value = URL(string: pattern)?.scheme
            if value == nil || value?.isEmpty ?? true {
                pattern = scheme + "://" + pattern
            }
            guard let patternURL = PatternURL(string: pattern) else {
                assertionFailure("\(pattern) is invalid")
                continue
            }
            let route = Route(pattern: patternURL, handler: handler)
            self.routes.append(route)
        }
    }
}

public extension Router where UserInfo == Void {
    @discardableResult
    public func openIfPossible(_ url: URL) -> Bool {
        return openIfPossible(url, userInfo: ())
    }

    public func responds(to url: URL) -> Bool {
        return responds(to: url, userInfo: ())
    }
}
