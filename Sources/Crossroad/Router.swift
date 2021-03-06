import Foundation

public typealias SimpleRouter = Router<Void>

public final class Router<UserInfo> {
    private let prefixes: Set<PatternURL.Prefix>
    private var routes: [Route<UserInfo>] = []

    public init(scheme: String) {
        prefixes = [.scheme(scheme.lowercased())]
    }

    public init(url: URL) {
        prefixes = [.url(url)]
    }

    private func shouldAccept(_ patternURL: PatternURL) -> Bool {
        switch patternURL.matchingPattern {
        case .any:
            return true
        case .specified:
            return true
        }
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

    public func register(_ routes: [(String, Route<UserInfo>.Handler)]) {
        for (patternString, handler) in routes {
            if patternString.hasPrefix("/") {
                let patternURL = PatternURL(matchingPattern: .any, path: patternString)
                let route = Route(pattern: patternURL, handler: handler)
                register(route)
            } else if patternString.contains("://") {
                let bits = patternString.components(separatedBy: "://")
                guard let patternScheme = bits.first else {
                    fatalError("Unknown situation")
                }
                guard let trailingPath = bits.last, bits.count == 2 else {
                    fatalError("Invalid Pattern \(patternString)")
                }
                for prefix in prefixes {
                    switch prefix {
                    case .scheme(let prefixScheme):
                        guard prefixScheme == patternScheme else {
                            continue
                        }
                        let patternURL = PatternURL(matchingPattern: .specified(.scheme(prefixScheme)), path: trailingPath)
                        let route = Route(pattern: patternURL, handler: handler)
                        register(route)
                    case .url(let prefixURL):
                        guard prefixURL.scheme == patternScheme else {
                            continue
                        }
                        guard let prefixRange = patternString.range(of: prefixURL.absoluteString) else {
                            continue
                        }
                        
                        let firstIndexOfRemaining = patternString.index(after: prefixRange.upperBound)
                        let ramainingPathRange = firstIndexOfRemaining...
                        let remainingPath = String(patternString[ramainingPathRange])
                        
                        let patternURL = PatternURL(matchingPattern: .specified(.url(prefixURL)), path: remainingPath)
                        let route = Route(pattern: patternURL, handler: handler)
                        register(route)
                    }
                }
            } else {
                fatalError("Invalid Pattern \(patternString)")
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
