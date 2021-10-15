import Foundation

enum DSL {
    struct RouteContainer {
    }
}

@resultBuilder
public struct RouteBuilder<UserInfo> {
    public static func buildBlock(_ components: Route<UserInfo>...) -> [Route<UserInfo>] {
        return []
    }
}

extension Router {
    public convenience init(_ linkSources: Set<LinkSource>, @RouteBuilder<UserInfo> routeBuilder: () -> [Route<UserInfo>]) {
        let routes = routeBuilder()
        self.init(linkSources: linkSources, routes: routes)
    }
}

extension Route {
    public init(_ path: Path, handler: @escaping Handler) {
        self.init(acceptableSources: [],
                  path: path,
                  handler: handler)
    }
}
