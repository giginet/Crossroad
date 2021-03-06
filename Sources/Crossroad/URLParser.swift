import Foundation

private let keywordPrefix = ":"

public struct URLParser<UserInfo> {
    public init() { }

    public func parse(_ url: URL, in patternURLString: String, userInfo: UserInfo) -> Context<UserInfo>? {
        guard let patternURL = buildPatternURL(patternURLString: patternURLString) else {
            return nil
        }
        return parse(url, in: patternURL, userInfo: userInfo)
    }

    func parse(_ url: URL, in patternURL: PatternURL, userInfo: UserInfo) -> Context<UserInfo>? {
        guard let host = url.host else {
            return nil
        }
        guard patternURL.hasPrefix(url) else {
            return nil
        }
    
        var arguments: Arguments = [:]
        if patternURL.host.hasPrefix(keywordPrefix) {
            let keyword = String(patternURL.host[keywordPrefix.endIndex...])
            arguments[keyword] = url.host
        } else if host.lowercased() != patternURL.host.lowercased() {
            return nil
        }

        for (patternComponent, component) in zip(patternURL.pathComponents, url.pathComponents) {
            if patternComponent.hasPrefix(keywordPrefix) {
                let keyword = String(patternComponent[keywordPrefix.endIndex...])
                arguments[keyword] = component
            } else if patternComponent == component {
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

extension URLParser where UserInfo == Void {
    public func parse(_ url: URL, in patternURLString: String) -> Context<UserInfo>? {
        return parse(url, in: patternURLString, userInfo: ())
    }
}
