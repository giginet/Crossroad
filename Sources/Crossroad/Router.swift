import Foundation

public typealias SimpleRouter = Router<Void>

public final class Router<UserInfo> {
    public typealias Route = Crossroad.Route<UserInfo>

    let linkSources: Set<LinkSource>
    private(set) var routes: [Route]
    private let parser = ContextParser<UserInfo>()

    public convenience init(accepts linkSource: LinkSource) {
        self.init(linkSources: [linkSource])
    }

    public convenience init(accepts linkSources: Set<LinkSource>) {
        self.init(linkSources: linkSources)
    }

    init(linkSources: Set<LinkSource>) {
        self.linkSources = linkSources
        self.routes = []
    }

    init(linkSources: Set<LinkSource>, routes: [Route]) throws {
        self.linkSources = linkSources
        self.routes = routes

        let validator = Validator(router: self)
        try validator.validate()
    }

    @available(*, deprecated, message: "Use new DSL instead. This method would cause fatalError when registered Routes are invalid for safety.", renamed: "init(accepts:_:)")
    public func register(_ routeDefinitions: [(String, Route.Handler)]) {
        let routes = routeDefinitions.map { (patternString, handler) -> Route in
            do {
                return try Route(patternString: patternString,
                                 acceptPolicy: .any,
                                 handler: handler)
            } catch {
                fatalError((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
            }
        }
        self.routes.append(contentsOf: routes)
        let validator = Validator(router: self)
        do {
            try validator.validate()
        } catch {
            fatalError((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
        }
    }

    @discardableResult
    public func openIfPossible(_ url: URL, userInfo: UserInfo) -> Bool {
        searchMatchingRoutes(to: url, userInfo: userInfo)
            .first { result in
                do {
                    return try result.route.executeHandler(context: result.context)
                } catch {
                    return false
                }
            } != nil
    }

    public func responds(to url: URL, userInfo: UserInfo) -> Bool {
        !searchMatchingRoutes(to: url, userInfo: userInfo).isEmpty
    }

    private func expandAcceptablePattern(of route: Route) -> Set<Pattern> {
        let validSources: Set<LinkSource>
        switch route.acceptPolicy {
        case .any:
            validSources = linkSources
        case .only(let accepteds):
            validSources = linkSources.intersection(accepteds)
        }
        return Set(validSources.map { Pattern(linkSource: $0, path: route.path) })
    }

    private struct MatchResult {
        let route: Route
        let context: Context<UserInfo>
    }
    private func searchMatchingRoutes(to url: URL, userInfo: UserInfo) -> [MatchResult] {
        routes.reduce(into: []) { matchings, route in
            for pattern in expandAcceptablePattern(of: route) {
                if let context = try? parser.parse(url, in: pattern, userInfo: userInfo) {
                    let result = MatchResult(route: route, context: context)
                    matchings.append(result)
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

public extension Router {
    @available(*, deprecated, renamed: "init(accepts:)")
    convenience init(scheme: String) {
        self.init(accepts: [.customURLScheme(scheme)])
    }

    @available(*, deprecated, renamed: "init(accepts:)")
    convenience init(url: URL) {
        self.init(accepts: [.universalLink(url)])
    }
}
