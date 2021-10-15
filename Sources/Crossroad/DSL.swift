import Foundation

public struct R {
    public enum AcceptPolicy {
        case any
        case onlyFor(Set<LinkSource>)
    }
    fileprivate var path: Path
    fileprivate var acceptPolicy: AcceptPolicy
    fileprivate var handler: (ContextProtocol) -> Bool

    public init(_ path: Path,
                accepts acceptPolicy: AcceptPolicy = .any,
                handler: @escaping (ContextProtocol) -> Bool) {
        self.path = path
        self.acceptPolicy = acceptPolicy
        self.handler = handler
    }
}

@resultBuilder
public struct RouteBuilder {
    public static func buildBlock(_ components: R...) -> [R] {
        components
    }
}

extension Router {
    public convenience init(_ linkSources: Set<LinkSource>, @RouteBuilder routeBuilder: () -> [R]) {
        let routes = routeBuilder().map { r in
            Route<UserInfo>(acceptableSources: linkSources,
                            path: r.path,
                            handler: r.handler)
        }
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
