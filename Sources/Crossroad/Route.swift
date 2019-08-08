import Foundation

public struct Route<UserInfo> {
    public typealias Handler = (Context<UserInfo>) -> Bool

    internal let patternURL: PatternURL
    private let handler: Handler
    private let parser: URLParser<UserInfo> = .init()

    internal init(pattern patternURL: PatternURL, handler: @escaping Handler) {
        self.patternURL = patternURL
        self.handler = handler
    }

    internal func responds(to url: URL, userInfo: UserInfo) -> Bool {
        return parser.parse(url, in: patternURL, userInfo: userInfo) != nil
    }

    internal func openIfPossible(_ url: URL, userInfo: UserInfo) -> Bool {
        guard let context = parser.parse(url, in: patternURL, userInfo: userInfo) else {
            return false
        }
        return handler(context)
    }
}
