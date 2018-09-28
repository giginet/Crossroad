import Foundation

public typealias SimpleRouter = Router<Void>

public enum RoutingType {
    case scheme(String)
    case baseURL(URL)
}

public final class Router<UserInfo> {
    private let acceptingRoutingTypes: [RoutingType]
    private var routes: [Route<UserInfo>] = []
    
    public init(accepts routingTypes: [RoutingType]) {
        self.acceptingRoutingTypes = routingTypes
    }

    internal func register(_ route: Route<UserInfo>) {
        let matchingRoutingType = acceptingRoutingTypes.first { route.match(routingType: $0) }
        if matchingRoutingType == nil {
            //assertionFailure("Router and pattern must have the following schemes: \(schemes.joined(separator: ", ")), actual: \(route.patternURL.scheme)")
        } else {
            routes.append(route)
        }
    }

    @discardableResult
    public func openIfPossible(_ url: URL, userInfo: UserInfo) -> Bool {
        return routes.first { $0.openIfPossible(url, userInfo: userInfo) } != nil
    }

    public func responds(to url: URL, userInfo: UserInfo) -> Bool {
        return routes.first { $0.responds(to: url, userInfo: userInfo) } != nil
    }

    public func register(_ routes: [(String, Route<UserInfo>.Handler)]) {
        for (pattern, handler) in routes {
            for routingType in acceptingRoutingTypes {
                switch routingType {
                case .scheme(let scheme):
                    let patternURLString: String
                    if pattern.hasPrefix("\(scheme)://") {
                        patternURLString = pattern
                    } else {
                        patternURLString = "\(scheme)://\(pattern)"
                    }
                    guard let patternURL = PatternURL(string: patternURLString) else {
                        assertionFailure("\(pattern) is invalid")
                        continue
                    }
                    let route = Route(pattern: patternURL, handler: handler)
                    register(route)
                case .baseURL(let baseURL):
                    break
                }
            }
        }
    }
}

public extension Router where UserInfo == Void {
    @discardableResult
    public func openIfPossible(_ url: URL) -> Bool {
        return openIfPossible(url, userInfo: ())
    }

    public func responds(to url: URL) -> Bool {
        return responds(to: url, userInfo: ())
    }
}
