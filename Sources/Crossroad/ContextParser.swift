import Foundation

@available(*, deprecated, renamed: "ContextParser")
public typealias URLParser = ContextParser

public class ContextParser<UserInfo> {
    private let keywordPrefix = ":"

    public enum Error: Swift.Error {
        case schemeIsMismatch
        case componentIsMismatch(expected: String, actual: String)
        case componentsCountMismatch
        case invalidURL
    }

    public init() { }

    public func parse(_ url: URL, with patternString: String, userInfo: UserInfo) throws -> Context<UserInfo> {
        let pattern = try Pattern(patternString: patternString)
        return try parse(url, with: pattern, userInfo: userInfo)
    }

    @available(*, deprecated, renamed: "parse(_:with:userInfo:)")
    public func parse(_ url: URL, in patternString: String, userInfo: UserInfo) throws -> Context<UserInfo> {
        try parse(url, with: patternString, userInfo: userInfo)
    }

    func parse(_ url: URL, with pattern: Pattern, userInfo: UserInfo) throws -> Context<UserInfo> {
        let expectedComponents: [String]
        let actualURLComponents: [String]
        let shouldBeCaseSensitives: [Bool]

        switch pattern.linkSource {
        case .customURLScheme(let scheme):
            guard url.scheme?.lowercased() == scheme.lowercased() else { throw Error.schemeIsMismatch }

            expectedComponents = pattern.path.components
            let host = url.host
            actualURLComponents = [host].compactMap { $0 } + url.pathComponents.droppedSlashElement() // pathComponents + host
            shouldBeCaseSensitives = [false] + Array(repeating: true, count: url.pathComponents.count)

        case .universalLink(let universalLinkURL):
            guard url.scheme?.lowercased() == universalLinkURL.scheme?.lowercased() else { throw Error.schemeIsMismatch }

            expectedComponents = pattern.path.components
            actualURLComponents = url.pathComponents.droppedSlashElement() // only pathComponents
            shouldBeCaseSensitives = Array(repeating: true, count: url.pathComponents.count)
        case .none:
            throw Error.invalidURL
        }

        guard expectedComponents.count == actualURLComponents.count else {
            throw Error.componentsCountMismatch
        }

        var arguments: Arguments.Storage = [:]
        for ((patternComponent, component), shouldBeCaseSensitive) in zip(zip(expectedComponents, actualURLComponents), shouldBeCaseSensitives) {
            if patternComponent.hasPrefix(keywordPrefix) {
                let keyword = String(patternComponent[keywordPrefix.endIndex...])
                arguments[keyword] = component
            } else if compare(patternComponent, component, isCaseSensitive: shouldBeCaseSensitive) {
                continue
            } else {
                throw Error.componentIsMismatch(expected: patternComponent, actual: component)
            }
        }

        let argumentContainer = Arguments(arguments)
        let parameters = parseParameters(from: url)
        return Context<UserInfo>(url: url, arguments: argumentContainer, queryParameters: parameters, userInfo: userInfo)
    }

    private func compare(_ lhs: String, _ rhs: String, isCaseSensitive: Bool) -> Bool {
        if isCaseSensitive {
            return lhs == rhs
        } else {
            return lhs.lowercased() == rhs.lowercased()
        }
    }

    private func parseParameters(from url: URL) -> QueryParameters {
        let parameters: QueryParameters.Storage
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            parameters = components.queryItems ?? []
        } else {
            parameters = []
        }
        return QueryParameters(parameters)
    }
}

extension ContextParser where UserInfo == Void {
    public func parse(_ url: URL, with patternString: String) throws -> Context<UserInfo> {
        return try parse(url, with: patternString, userInfo: ())
    }

    @available(*, deprecated, renamed: "parse(_:with:)")
    public func parse(_ url: URL, in patternString: String) throws -> Context<UserInfo> {
        try parse(url, with: patternString, userInfo: ())
    }
}
