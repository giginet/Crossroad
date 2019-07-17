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
        guard let scheme = url.scheme?.lowercased(), let host = url.host else {
            return nil
        }
        if scheme != patternURL.scheme.lowercased() || patternURL.pathComponents.count != url.pathComponents.count {
            return nil
        }

        var arguments: Arguments = [:]
        if patternURL.host.lowercased().hasPrefix(PatternURL.keywordPrefix.lowercased()) {
            let keyword = String(patternURL.host[PatternURL.keywordPrefix.endIndex...])
            arguments[keyword] = host
        } else if host.lowercased() != patternURL.host.lowercased() {
            return nil
        }

        for (patternComponent, component) in zip(patternURL.pathComponents, url.pathComponents) {
            if patternComponent.lowercased().hasPrefix(PatternURL.keywordPrefix.lowercased()) {
                let keyword = String(patternComponent[PatternURL.keywordPrefix.endIndex...])
                arguments[keyword] = component
            } else if patternComponent.lowercased() == component.lowercased() {
                continue
            } else {
                return nil
            }
        }
        let parameters: Parameters
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            parameters = components.queryItems ?? []
        } else {
            parameters = []
        }
        return Context<UserInfo>(url: url, arguments: arguments, parameters: parameters, userInfo: userInfo)
    }
}
