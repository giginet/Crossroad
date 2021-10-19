import Foundation

public struct Route<UserInfo> {
    public typealias Handler = (Context<UserInfo>) throws -> Bool
    var pattern: Pattern
    var acceptPolicy: AcceptPolicy
    var handler: Handler

    public enum AcceptPolicy: Equatable {
        case any
        case only(for: Set<LinkSource>)
        public static func only(for linkSource: LinkSource) -> Self {
            .only(for: [linkSource])
        }
    }

    var path: Path {
        pattern.path
    }

    init(patternString: String, acceptPolicy: AcceptPolicy, handler: @escaping Handler) throws {
        self.pattern = try Pattern(patternString: patternString)
        self.acceptPolicy = acceptPolicy
        self.handler = handler
    }

    func executeHandler(context: Context<UserInfo>) throws -> Bool {
        try handler(context)
    }
}
