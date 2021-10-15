import Foundation

public class Parser {
    private static let keywordPrefix = ":"

    public func parse(_ url: URL, in pattern: Pattern) -> Context<Void>? {
        guard validate(url, expected: pattern) else { return nil }

        let arguments: Arguments
        switch pattern.linkSource {
        case .universalLink:
            let componentsToCompare = url.pathComponents.droppedSlashElement()
            arguments = parseArguments(componentsToCompare: componentsToCompare, path: pattern.path)
        case .urlScheme:
            guard let host = url.host else { return nil }
            let componentsToCompare = [host] + url.pathComponents.droppedSlashElement()
            arguments = parseArguments(componentsToCompare: componentsToCompare, path: pattern.path)
        }
        let parameters = parseParameters(from: url)
        return Context<Void>(url: url, arguments: arguments, parameters: parameters)
    }

    private func validate(_ url: URL, expected pattern: Pattern) -> Bool {
        switch pattern.linkSource {
        case .urlScheme(let scheme):
            guard url.scheme == scheme else { return false }
            let expectedElementCount = pattern.path.components.count
            let actualElementCount = url.pathComponents.droppedSlashElement().count + 1 // pathComponents + host
            guard expectedElementCount == actualElementCount else { return false }
        case .universalLink(let universalLinkURL):
            guard url.scheme == universalLinkURL.scheme else { return false }
            let expectedElementCount = pattern.path.components.count
            let actualElementCount = url.pathComponents.droppedSlashElement().count // only pathComponents
            guard expectedElementCount == actualElementCount else { return false }
        }
        return true
    }

    private func parseArguments(componentsToCompare: [String], path: Path) -> Arguments {
        var arguments: Arguments = [:]
        for (patternComponent, component) in zip(componentsToCompare, path.components) {
            if patternComponent.hasPrefix(Self.keywordPrefix) {
                let keyword = String(patternComponent[Self.keywordPrefix.endIndex...])
                arguments[keyword] = component
            } else if patternComponent == component {
                continue
            } else {
                return [:]
            }
        }
        return arguments
    }

    private func parseParameters(from url: URL) -> Parameters {
        let parameters: Parameters
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            parameters = components.queryItems ?? []
        } else {
            parameters = []
        }
        return parameters
    }
}

extension Collection where Element == String {
    fileprivate func droppedSlashElement() -> [String] {
        filter { $0 != "/" }
    }
}
