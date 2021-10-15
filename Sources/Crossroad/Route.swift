import Foundation

public protocol Handler {
    associatedtype UserInfo
    func execute(context: Context<UserInfo>) -> Bool
}

fileprivate struct ClosureHandler<UserInfo>: Handler {
    func execute(context: Context<UserInfo>) -> Bool {
        return closure(context)
    }

    typealias Closure = (Context<UserInfo>) -> Bool

    var closure: Closure

    init(closure: @escaping Closure) {
        self.closure = closure
    }
}

class AnyHandler<UserInfo> {
    private let executor: (Context<UserInfo>) -> Bool

    fileprivate init<H: Handler>(inner: H) where H.UserInfo == UserInfo {
        self.executor = { context in
            inner.execute(context: context)
        }
    }

    fileprivate func execute(context: Context<UserInfo>) -> Bool {
        executor(context)
    }
}

struct Route<UserInfo> {
    var acceptableSources: Set<LinkSource>
    var path: Path
    var handler: AnyHandler<UserInfo>

    func expandAcceptablePattern() -> Set<Pattern> {
        Set(acceptableSources.map { Pattern(linkSource: $0, path: path) })
    }

    func executeHandler(context: Context<UserInfo>) -> Bool {
        handler.execute(context: context)
    }
}
