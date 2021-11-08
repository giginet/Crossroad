import Foundation

extension Router {
    @resultBuilder
    public struct RouteBuilder {
        public static func buildBlock(_ components: [Definition]...) -> [Definition] {
            components.reduce(into: []) { $0.append(contentsOf: $1) }
        }
    }

    public convenience init(accepting linkSources: Set<LinkSource>, @RouteBuilder _ routeBuilder: (Definition.Factory) -> [Definition]) throws {
        let routeDefinitions = routeBuilder(Definition.Factory())
        let routes = try routeDefinitions.map { definition in
            try definition.get()
        }
        try self.init(linkSources: linkSources, routes: routes)
    }

    public struct Definition {
        private let result: Result<Route, Error>

        fileprivate init(_ patternString: String, accepting acceptPolicy: Route.AcceptPolicy = .any, handler: @escaping Route.Handler) {
            do {
                let route = try Route(patternString: patternString,
                                      acceptPolicy: acceptPolicy,
                                      handler: handler)
                result = .success(route)
            } catch {
                result = .failure(error)
            }
        }

        fileprivate func get() throws -> Route {
            try result.get()
        }

        public struct Factory {
            public func callAsFunction(_ patternString: String, accepting acceptPolicy: Route.AcceptPolicy = .any, handler: @escaping Route.Handler) -> [Definition] {
                [Definition(patternString, accepting: acceptPolicy, handler: handler)]
            }

            public func group(accepting linkSources: Set<LinkSource>, @RouteBuilder _ routeBuilder: (Definition.GrouptedRouteFactory) -> [Definition]) -> [Definition] {
                routeBuilder(GrouptedRouteFactory(parentLinkSources: linkSources))
            }

            public func group(accepting linkSource: LinkSource, @RouteBuilder _ routeBuilder: (Definition.GrouptedRouteFactory) -> [Definition]) -> [Definition] {
                group(accepting: [linkSource], routeBuilder)
            }
        }

        public struct GrouptedRouteFactory {
            private let parentLinkSources: Set<LinkSource>
            fileprivate init(parentLinkSources: Set<LinkSource>) {
                self.parentLinkSources = parentLinkSources
            }

            public func callAsFunction(_ patternString: String, handler: @escaping Route.Handler) -> [Definition] {
                [Definition(patternString, accepting: .only(for: parentLinkSources), handler: handler)]
            }
        }
    }
}
