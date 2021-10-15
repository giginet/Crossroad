import Foundation

public class Parser {
    private static let keywordPrefix = ":"

    public enum Error: Swift.Error {
        case schemeIsMismatch
        case componentIsMismatch(expected: String, actual: String)
        case componentsCountMismatch
        case invalidURL
    }

    public init() { }

    public func parse(_ url: URL, in pattern: Pattern) throws -> Context<Void>? {
        let patternComponents: [String]
        let actualURLComponents: [String]

        switch pattern.linkSource {
        case .urlScheme(let scheme):
            guard url.scheme?.lowercased() == scheme.lowercased() else { throw Error.schemeIsMismatch }
            patternComponents = pattern.path.components
            guard let host = url.host else { throw Error.invalidURL }
            actualURLComponents = [host] + url.pathComponents.droppedSlashElement() // pathComponents + host
        case .universalLink(let universalLinkURL):
            guard url.scheme?.lowercased() == universalLinkURL.scheme?.lowercased() else { throw Error.schemeIsMismatch }
            patternComponents = pattern.path.components
            actualURLComponents = url.pathComponents.droppedSlashElement() // only pathComponents
        case .none:
            throw Error.invalidURL
        }

        guard patternComponents.count == actualURLComponents.count else {
            throw Error.componentsCountMismatch
        }

        var arguments: Arguments = [:]
        for (index, (patternComponent, component)) in zip(patternComponents, actualURLComponents).enumerated() {
            let shouldBeCaseSensitive: Bool
            switch pattern.linkSource {
            case .urlScheme:
                // host must be case insensitive. pathes must be case sensitive.
                shouldBeCaseSensitive = index != 0
            case .universalLink:
                shouldBeCaseSensitive = true
            case .none:
                throw Error.invalidURL
            }

            if patternComponent.hasPrefix(Self.keywordPrefix) {
                let keyword = String(patternComponent[Self.keywordPrefix.endIndex...])
                arguments[keyword] = component
            } else if compare(patternComponent, component, isCaseSensitive: shouldBeCaseSensitive) {
                continue
            } else {
                throw Error.componentIsMismatch(expected: patternComponent, actual: component)
            }
        }

        let parameters = parseParameters(from: url)
        return Context<Void>(url: url, arguments: arguments, parameters: parameters)
    }

    private func compare(_ lhs: String, _ rhs: String, isCaseSensitive: Bool) -> Bool {
        if isCaseSensitive {
            return lhs == rhs
        } else {
            return lhs.lowercased() == rhs.lowercased()
        }
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
