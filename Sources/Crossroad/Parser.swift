import Foundation
import UIKit

@available(*, deprecated, message: "URLParser<UserInfo> is deprecated. Please use Parser instead.", renamed: "Parser")
public class URLParser<UserInfo> {
    @available(*, deprecated)
    public init() {
        fatalError()
    }

    @available(*, deprecated)
    public func parse(_ url: URL, in patternString: String) throws -> Context<Void>? {
        fatalError()
    }
}

public class Parser {
    private static let keywordPrefix = ":"

    public enum Error: Swift.Error {
        case schemeIsMismatch
        case componentIsMismatch(expected: String, actual: String)
        case componentsCountMismatch
        case invalidURL
    }

    public init() { }

    public func parse(_ url: URL, in patternString: String) throws -> Context<Void>? {
        let pattern = try Pattern(patternString: patternString)
        return try parse(url, in: pattern)
    }

    public func parse(_ url: URL, in pattern: Pattern) throws -> Context<Void>? {
        let expectedComponents: [String]
        let actualURLComponents: [String]
        let shouldBeCaseSensitives: [Bool]

        switch pattern.linkSource {
        case .customURLScheme(let scheme):
            guard url.scheme?.lowercased() == scheme.lowercased() else { throw Error.schemeIsMismatch }

            expectedComponents = pattern.path.components
            guard let host = url.host else { throw Error.invalidURL }
            actualURLComponents = [host] + url.pathComponents.droppedSlashElement() // pathComponents + host
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
            if patternComponent.hasPrefix(Self.keywordPrefix) {
                let keyword = String(patternComponent[Self.keywordPrefix.endIndex...])
                arguments[keyword] = component
            } else if compare(patternComponent, component, isCaseSensitive: shouldBeCaseSensitive) {
                continue
            } else {
                throw Error.componentIsMismatch(expected: patternComponent, actual: component)
            }
        }

        let argumentContainer = Arguments(arguments)
        let parameters = parseParameters(from: url)
        return Context<Void>(url: url, arguments: argumentContainer, parameters: parameters)
    }

    private func compare(_ lhs: String, _ rhs: String, isCaseSensitive: Bool) -> Bool {
        if isCaseSensitive {
            return lhs == rhs
        } else {
            return lhs.lowercased() == rhs.lowercased()
        }
    }

    private func parseParameters(from url: URL) -> Parameters {
        let parameters: Parameters.Storage
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            parameters = components.queryItems ?? []
        } else {
            parameters = []
        }
        return Parameters(parameters)
    }
}
