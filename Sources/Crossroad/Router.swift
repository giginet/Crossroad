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
        prefix = .scheme(scheme.lowercased())
    }

    public init(url: URL) {
        prefix = .url(url)
    }

    private func isValidURLPattern(_ patternURL: PatternURL) -> Bool {
        switch prefix {
        case .scheme(let scheme):
            return scheme.lowercased() == patternURL.scheme.lowercased()
        case .url(let url):
            return patternURL.hasPrefix(url: url)
        }
    }

    internal func register(_ route: Route<UserInfo>) {
        if isValidURLPattern(route.patternURL) {
            routes.append(route)
        } else {
            assertionFailure("Unexpected URL Pattern")
        }
    }

    @discardableResult
    public func openIfPossible(_ url: URL, userInfo: UserInfo) -> Bool {
        return routes.first { $0.openIfPossible(url, userInfo: userInfo) } != nil
    }

    public func responds(to url: URL, userInfo: UserInfo) -> Bool {
        return routes.first { $0.responds(to: url, userInfo: userInfo) } != nil
    }

    private func canonicalizePattern(_ pattern: String) -> String {
        if pattern.hasPrefix("/") {
            return String(pattern.dropFirst())
        }
        return pattern
    }

    public func register(_ routes: [(String, Route<UserInfo>.Handler)]) {
        for (pattern, handler) in routes {
            let patternURLString: String
            switch prefix {
            case .scheme(let scheme):
                if pattern.lowercased().hasPrefix("\(scheme)://") {
                    patternURLString = canonicalizePattern(pattern)
                } else {
                    patternURLString = "\(scheme)://\(canonicalizePattern(pattern))"
                }
            case .url(let url):
                if pattern.lowercased().hasPrefix(url.absoluteString) {
                    patternURLString = canonicalizePattern(pattern)
                } else {
                    patternURLString = url.appendingPathComponent(canonicalizePattern(pattern)).absoluteString
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
