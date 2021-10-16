import Foundation

extension Router {
    @resultBuilder
    public struct RouterBuilder {
        public static func buildBlock(_ components: Definition...) -> [Definition] {
            components
        }
    }

    public convenience init(accepts linkSources: Set<LinkSource>, @RouterBuilder routeBuilder: (Definition.Factory) -> [Definition]) throws {
        let routeDefinitions = routeBuilder(Definition.Factory())
        let routes = try routeDefinitions.map { definition in
            try definition.get()
        }
        try self.init(linkSources: linkSources, routes: routes)
    }

    public struct Definition {
        private let result: Result<Route, Error>

        public init(_ patternString: String, accepts acceptPolicy: Route.AcceptPolicy = .any, handler: @escaping Route.Handler) {
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
            public func callAsFunction(_ patternString: String, accepts acceptPolicy: Route.AcceptPolicy = .any, handler: @escaping Route.Handler) -> Definition {
                Definition(patternString, accepts: acceptPolicy, handler: handler)
            }
        }
    }
}
