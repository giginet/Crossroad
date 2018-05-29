import Foundation

public struct Route<UserInfo> {
    public typealias Handler = (Context<UserInfo>) -> Bool

    internal let patternURL: PatternURL
    private let handler: Handler

    internal init(pattern patternURL: PatternURL, handler: @escaping Handler) {
        self.patternURL = patternURL
        self.handler = handler
    }

    internal func responds(to url: URL, userInfo: UserInfo) -> Bool {
        return parse(url, with: userInfo) != nil
    }

    internal func openIfPossible(_ url: URL, userInfo: UserInfo) -> Bool {
        guard let context = parse(url, with: userInfo) else {
            return false
        }
        return handler(context)
    }

    internal func parse(_ url: URL, with userInfo: UserInfo) -> Context<UserInfo>? {
        guard let scheme = url.scheme, let host = url.host else {
            return nil
        }
        if scheme != patternURL.scheme || patternURL.pathComponents.count != url.pathComponents.count {
            return nil
        }

        var arguments: [String: String] = [:]
        if patternURL.host.hasPrefix(PatternURL.keywordPrefix) {
            let keyword = String(patternURL.host[PatternURL.keywordPrefix.endIndex...])
            arguments[keyword] = host
        } else if host != patternURL.host {
            return nil
        }

        for (patternComponent, component) in zip(patternURL.pathComponents, url.pathComponents) {
            if patternComponent.hasPrefix(PatternURL.keywordPrefix) {
                let keyword = String(patternComponent[PatternURL.keywordPrefix.endIndex...])
                arguments[keyword] = component
            } else if patternComponent == component {
                continue
            } else {
                return nil
            }
        }
        let parameters: [URLQueryItem]
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            parameters = components.queryItems ?? []
        } else {
            parameters = []
        }
        return Context<UserInfo>(url: url, arguments: arguments, parameters: parameters, userInfo: userInfo)
    }
}
