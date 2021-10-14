import Foundation
import UIKit

public enum Source: Hashable {
    case urlScheme(String)
    case universalLink(URL)

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .urlScheme(let scheme):
            hasher.combine(scheme)
        case .universalLink(let url):
            hasher.combine(url)
        }
    }
}

public class Router<UserInfo> {
    var routes: [Route<UserInfo>] = []

    func register(_ route: Route<UserInfo>) {
        routes.append(route)
    }
}

public struct Path {
    var components: [String]

    var absoluteString: String {
        "/" + components.joined(separator: "/")
    }
}

public protocol Handler {
    func handle<UserInfo>(context: Context<UserInfo>)
}

fileprivate struct ClosureHandler<UserInfo>: Handler {
    func handle<UserInfo>(context: Context<UserInfo>) {
    }

    typealias Closure = (Context<UserInfo>) -> Void

    var closure: Closure

    init(closure: @escaping Closure) {
        self.closure = closure
    }
}

struct Route<UserInfo> {
    var acceptableSources: Set<Source>
    var path: Path
    var handler: Handler
}

