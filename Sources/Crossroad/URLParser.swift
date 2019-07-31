import Foundation

public struct URLParser<UserInfo> {
    func parse(_ url: URL, in patternURL: PatternURL, userInfo: UserInfo) -> Context<UserInfo>? {
        var arguments: Arguments = [:]
        
        switch patternURL.pathType {
        case .absolute(let patternURLScheme, let patternURLHost):
            guard let targetURLScheme = url.scheme, let targetURLHost = url.host else {
                return nil
            }
            if patternURLScheme == targetURLScheme || patternURL.pathComponents.count != url.pathComponents.count {
                return nil
            }
            
            if targetURLHost.hasPrefix(PatternURL.keywordPrefix) {
                let keyword = String(targetURLHost[PatternURL.keywordPrefix.endIndex...])
                arguments[keyword] = targetURLHost
            } else if targetURLHost != patternURLHost {
                return nil
            }
        case .relative:
            break
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
    func parse(_ url: URL, in patternURL: PatternURL) -> Context<UserInfo>? {
        return parse(url, in: patternURL, userInfo: ())
    }
}
