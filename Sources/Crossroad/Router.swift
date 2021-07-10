import Foundation

public typealias SimpleRouter = Router<Void>

public final class Router<UserInfo> {
    private enum Prefix {
        case scheme(String)
        case url(URL)
        case multiple(scheme: String, url: URL)
    }
    private let prefix: Prefix
    private var routes: [Route<UserInfo>] = []

    public init(scheme: String) {
        prefix = .scheme(scheme.lowercased())
    }

    public init(url: URL) {
        prefix = .url(url)
    }
    
    public init(scheme: String, url: URL) {
        prefix = .multiple(scheme: scheme, url: url)
    }

    private func isValidURLPattern(_ patternURL: PatternURL) -> Bool {
        switch prefix {
        case .scheme(let scheme):
            return scheme.lowercased() == patternURL.scheme.lowercased()
        case .url(let url):
            return patternURL.hasPrefix(url: url)
        case .multiple(scheme: let scheme, url: let url):
            return patternURL.hasPrefix(url: url) || scheme.lowercased() == patternURL.scheme.lowercased()
        }
    }

    internal func register(_ route: Route<UserInfo>) {
        if routes.contains(where: { element in
            element.patternURL == route.patternURL
        }) {
            assertionFailure("\(route.patternURL.patternString) is already registered")
        }
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
    
    private func generatePatternURLString(from pattern: String, scheme: String) -> String {
        if pattern.lowercased().hasPrefix("\(scheme)://") {
            return canonicalizePattern(pattern)
        } else {
            return "\(scheme)://\(canonicalizePattern(pattern))"
        }
    }
    
    private func generatePatternURLString(from pattern: String, url: URL) -> String {
        if pattern.lowercased().hasPrefix(url.absoluteString) {
            return canonicalizePattern(pattern)
        } else {
            return url.appendingPathComponent(canonicalizePattern(pattern)).absoluteString
        }
    }

    public func register(_ routes: [(String, Route<UserInfo>.Handler)]) {
        for (pattern, handler) in routes {
            switch prefix {
            case .scheme(let scheme):
                guard let patternSchemeURL = PatternURL(string: generatePatternURLString(from: pattern, scheme: scheme)) else {
                    assertionFailure("\(pattern) is invalid")
                    continue
                }
                register(Route(pattern: patternSchemeURL, handler: handler))
            case .url(let url):
                guard let patternURL = PatternURL(string: generatePatternURLString(from: pattern, url: url)) else {
                    assertionFailure("\(pattern) is invalid")
                    continue
                }
                register(Route(pattern: patternURL, handler: handler))
            case .multiple(scheme: let scheme, url: let url):
                guard let patternSchemeURL = PatternURL(string: generatePatternURLString(from: pattern, scheme: scheme)),
                      let patternURL = PatternURL(string: generatePatternURLString(from: pattern, url: url)) else {
                    assertionFailure("\(pattern) is invalid")
                    continue
                }
                register(Route(pattern: patternURL, handler: handler))
                register(Route(pattern: patternSchemeURL, handler: handler))
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
