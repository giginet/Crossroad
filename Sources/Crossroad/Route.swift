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

    init(patternString: String, acceptPolicy: AcceptPolicy, handler: @escaping Handler) {
        let pattern = try! Pattern(patternString: patternString)
        self.path = pattern.path
        self.acceptPolicy = acceptPolicy
        self.handler = handler
    }

    func executeHandler(context: Context<UserInfo>) -> Bool {
        handler(context)
    }
}
