import Foundation

@resultBuilder
public struct RouteBuilder<UserInfo> {
    public static func buildBlock(_ components: Route<UserInfo>...) -> [Route<UserInfo>] {
        components
    }
}

extension Router {
    public typealias Route = Crossroad.Route<UserInfo>

    public convenience init(accepts linkSources: Set<LinkSource>, @RouteBuilder<UserInfo> routeBuilder: () -> [Route]) throws {
        let routes = routeBuilder()
        try self.init(linkSources: linkSources, routes: routes)
    }
}

extension Route {
    public init(_ patternString: String, accepts acceptPolicy: AcceptPolicy = .any, handler: @escaping Handler) {
        self.init(patternString: patternString,
                  acceptPolicy: acceptPolicy,
                  handler: handler)
    }
}
