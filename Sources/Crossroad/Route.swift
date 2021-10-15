import Foundation

public struct Route<UserInfo> {
    public typealias Handler = (Context<UserInfo>) -> Bool
    var path: Path
    var acceptPolicy: AcceptPolicy
    var handler: Handler

    public enum AcceptPolicy {
        case any
        case onlyFor(Set<LinkSource>)
    }

    init(path: Path, acceptPolicy: AcceptPolicy, handler: @escaping Handler) {
        self.path = path
        self.acceptPolicy = acceptPolicy
        self.handler = handler
    }

    func executeHandler(context: Context<UserInfo>) -> Bool {
        handler(context)
    }
}

