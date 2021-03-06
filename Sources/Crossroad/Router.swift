import Foundation

public typealias SimpleRouter = Router<Void>

enum Prefix: Hashable {
    case scheme(String)
    case url(URL)
}

public final class Router<UserInfo> {
    private let prefixes: Set<Prefix>
    private var routes: [Route<UserInfo>] = []

    public init(scheme: String) {
        prefixes = [.scheme(scheme.lowercased())]
    }

    public init(url: URL) {
        prefixes = [.url(url)]
    }

    private func shouldAccept(_ patternURL: PatternURL) -> Bool {
        return true
//        prefixes.contains { prefix in
//            switch prefix {
//            case .scheme(let scheme):
//                return scheme.lowercased() == patternURL.scheme.lowercased()
//            case .url(let url):
//                return patternURL.hasPrefix(url: url)
//            }
//        }
    }

    internal func register(_ route: Route<UserInfo>) {
        if shouldAccept(route.patternURL) {
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
    
    private func splitPatternURL(_ patternURLString: String) -> (String?, String, [String])? {
        let bits = patternURLString.components(separatedBy: "://")
        let scheme: String?
        let host: String
        let components: [String]
        
        func splitHostAndComponents(_ string: String) -> (String, [String]) {
            let bits = string.components(separatedBy: "/")
            let host = bits.first!
            let components = Array(bits.dropFirst())
            return (host, components)
        }
        
        switch bits.count {
        case 1:
            scheme = nil
            (host, components) = splitHostAndComponents(bits.first!)
        case 2:
            scheme = bits.first
            (host, components) = splitHostAndComponents(bits.last!)
        default:
            return nil
        }
        
        return (scheme, host, components)
    }

    public func register(_ routes: [(String, Route<UserInfo>.Handler)]) {
        for (patternString, handler) in routes {
            
            guard let (patternScheme, patternHost, patternComponents) = splitPatternURL(patternString) else {
                continue
            }
            
            switch patternScheme {
            case .none:
                let patternURL = RelativePatternURL(host: patternHost, pathComponents: patternComponents)
                let route = Route(pattern: patternURL, handler: handler)
                register(route)
            case .some(let patternScheme):
                for prefix in prefixes {
                    switch prefix {
                    case .scheme(let prefixScheme):
                        guard prefixScheme.lowercased() == patternScheme.lowercased() else {
                            continue
                        }
                        let patternURL = AbsolutePatternURL(scheme: prefixScheme, host: patternHost, pathComponents: patternComponents)
                        let route = Route(pattern: patternURL, handler: handler)
                        register(route)
                    case .url(let prefixURL):
                        guard let patternURL = AbsolutePatternURL(url: prefixURL, pathComponents: patternComponents) else {
                            continue
                        }
                        let route = Route(pattern: patternURL, handler: handler)
                        register(route)
                    }
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
