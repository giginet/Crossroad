import Foundation

public struct Route<UserInfo> {
    public typealias Handler = (Context<UserInfo>) -> Bool
    var acceptableSources: Set<LinkSource>
    var path: Path
    var handler: Handler

    init(acceptableSources: Set<LinkSource>, path: Path, handler: @escaping Handler) {
        self.acceptableSources = acceptableSources
        self.path = path
        self.handler = handler
    }

    func expandAcceptablePattern() -> Set<Pattern> {
        Set(acceptableSources.map { Pattern(linkSource: $0, path: path) })
    }

    func executeHandler(context: Context<UserInfo>) -> Bool {
        handler(context)
    }
}
