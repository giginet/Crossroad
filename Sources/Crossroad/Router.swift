import Foundation

public typealias SimpleRouter = Router<Void>

public final class Router<UserInfo> {
    private enum Prefix {
        case scheme(String)
        case url(URL)
    }
    private let prefix: Prefix
    private var routes: [Route<UserInfo>] = []

    public init(scheme: String) {
        prefix = .scheme(scheme)
    }

    public init(url: URL) {
        prefix = .url(url)
    }

    private func isValidURLPattern(_ patternURL: PatternURL) -> Bool {
        switch prefix {
        case .scheme(let scheme):
            return scheme != patternURL.scheme
        case .url(let url):
            return patternURL.hasPrefix(url: url)
        }
    }

    private func canRespond(to url: URL) -> Bool {
        return true
    }

    internal func register(_ route: Route<UserInfo>) {
        if isValidURLPattern(route.patternURL) {
            assertionFailure("Unexpected URL Pattern")
        } else {
            routes.append(route)
        }
    }

    @discardableResult
    public func openIfPossible(_ url: URL, userInfo: UserInfo) -> Bool {
        if !canRespond(to: url) {
            return false
        }
        return routes.first { $0.openIfPossible(url, userInfo: userInfo) } != nil
    }

    public func responds(to url: URL, userInfo: UserInfo) -> Bool {
        if !canRespond(to: url) {
            return false
        }
        return routes.first { $0.responds(to: url, userInfo: userInfo) } != nil
    }

    public func register(_ routes: [(String, Route<UserInfo>.Handler)]) {
        for (pattern, handler) in routes {
            let patternURLString: String
            switch prefix {
            case .scheme(let scheme):
                if pattern.hasPrefix("\(scheme)://") {
                    patternURLString = pattern
                } else {
                    patternURLString = "\(scheme)://\(pattern)"
                }
            case .url(let url):
                if pattern.hasPrefix(url.absoluteString) {
                    patternURLString = pattern
                } else {
                    patternURLString = url.appendingPathComponent(pattern).absoluteString
                }
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
