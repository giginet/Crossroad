import Foundation

extension Router {
    public struct TopLevelRoute {
        @resultBuilder
        public struct Builder {
            public static func buildBlock(_ components: [Definition]...) -> [Definition] {
                components.reduce(into: []) { $0.append(contentsOf: $1) }
            }
        }

        public struct Registry {
            public func route(_ patternString: String, accepting acceptPolicy: Route.AcceptPolicy = .any, handler: @escaping Route.Handler) -> [Definition] {
                [Definition(patternString, acceptPolicy: acceptPolicy, handler: handler)]
            }

            public func group(accepting linkSources: Set<LinkSource>, @GroupedRoute.Builder _ routeBuilder: (GroupedRoute.Registry) -> [Definition]) -> [Definition] {
                routeBuilder(GroupedRoute.Registry(parentLinkSources: linkSources))
            }

            public func group(accepting linkSource: LinkSource, @GroupedRoute.Builder _ routeBuilder: (GroupedRoute.Registry) -> [Definition]) -> [Definition] {
                group(accepting: [linkSource], routeBuilder)
            }
        }

        public struct Definition {
            private let result: Result<Route, Error>

            fileprivate init(groupedRouteDefinition: GroupedRoute.Definition) {
                self.result = groupedRouteDefinition.result
            }

            fileprivate init(_ patternString: String, acceptPolicy: Route.AcceptPolicy, handler: @escaping Route.Handler) {
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
        }
    }

    public struct GroupedRoute {
        @resultBuilder
        public struct Builder {
            public static func buildBlock(_ components: [GroupedRoute.Definition]...) -> [TopLevelRoute.Definition] {
                components.reduce(into: []) { $0.append(contentsOf: $1.map(TopLevelRoute.Definition.init(groupedRouteDefinition:))) }
            }
        }

        public struct Registry {
            private let parentLinkSources: Set<LinkSource>
            fileprivate init(parentLinkSources: Set<LinkSource>) {
                self.parentLinkSources = parentLinkSources
            }

            public func route(_ patternString: String, handler: @escaping Route.Handler) -> [Definition] {
                [Definition(patternString, acceptPolicy: .only(for: parentLinkSources), handler: handler)]
            }
        }

        public struct Definition {
            fileprivate let result: Result<Route, Error>

            fileprivate init(_ patternString: String, acceptPolicy: Route.AcceptPolicy, handler: @escaping Route.Handler) {
                do {
                    let route = try Route(patternString: patternString,
                                          acceptPolicy: acceptPolicy,
                                          handler: handler)
                    result = .success(route)
                } catch {
                    result = .failure(error)
                }
            }
        }
    }

    public convenience init(accepting linkSources: Set<LinkSource>, @TopLevelRoute.Builder _ routeBuilder: (TopLevelRoute.Registry) -> [TopLevelRoute.Definition]) throws {
        let routeDefinitions = routeBuilder(TopLevelRoute.Registry())
        let routes = try routeDefinitions.map { definition in
            try definition.get() as Route
        }
        try self.init(linkSources: linkSources, routes: routes)
    }
}
