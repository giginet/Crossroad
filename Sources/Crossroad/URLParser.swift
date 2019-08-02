import Foundation

public struct URLParser<UserInfo> {
    func parse(_ url: URL, in patternURL: PatternURL, userInfo: UserInfo) -> Context<UserInfo>? {
        let caseInsensitiveURL = URL(string: url.absoluteString.lowercased()) ?? url
        guard let scheme = caseInsensitiveURL.scheme, let host = caseInsensitiveURL.host else {
            return nil
        }
        if scheme != patternURL.scheme || patternURL.pathComponents.count != caseInsensitiveURL.pathComponents.count {
            return nil
        }

        var arguments: Arguments = [:]
        if patternURL.host.hasPrefix(PatternURL.keywordPrefix) {
            let keyword = String(patternURL.host[PatternURL.keywordPrefix.endIndex...])
            arguments[keyword] = host
        } else if host != patternURL.host {
            return nil
        }

        for (patternComponent, component) in zip(patternURL.pathComponents, caseInsensitiveURL.pathComponents) {
            if patternComponent.hasPrefix(PatternURL.keywordPrefix) {
                let keyword = String(patternComponent[PatternURL.keywordPrefix.endIndex...])
                arguments[keyword] = component
            } else if patternComponent == component {
                continue
            } else {
                return nil
            }
        }
        let parameters: Parameters
        if let components = URLComponents(url: caseInsensitiveURL, resolvingAgainstBaseURL: true) {
            parameters = components.queryItems ?? []
        } else {
            parameters = []
        }
        return Context<UserInfo>(url: caseInsensitiveURL, arguments: arguments, parameters: parameters, userInfo: userInfo)
    }
}

extension URLParser where UserInfo == Void {
    func parse(_ url: URL, in patternURL: PatternURL) -> Context<UserInfo>? {
        return parse(url, in: patternURL, userInfo: ())
    }
}
