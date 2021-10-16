import Foundation

public enum LinkSource: Hashable {
    case urlScheme(String)
    case universalLink(URL)

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .urlScheme(let scheme):
            hasher.combine(scheme)
        case .universalLink(let url):
            hasher.combine(url)
        }
    }
}

public struct Path: Hashable {
    var components: [String]

    var absoluteString: String {
        "/" + components.joined(separator: "/")
    }

    init(components: [String]) {
        self.components = components
    }

    init(pathString: String) {
        self.components = pathString.split(separator: "/").map(String.init).droppedSlashElement()
    }
}

extension Path: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    public init(stringLiteral value: String) {
        self.init(pathString: value)
    }

    public init(unicodeScalarLiteral value: String) {
        self.init(pathString: value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(pathString: value)
    }
}

public struct Pattern: Hashable {
    public let linkSource: LinkSource?
    public let path: Path

    public init(linkSource: LinkSource?, path: Path) {
        self.linkSource = linkSource
        self.path = path
    }

    public init(patternString: String) throws {
        let (linkSource, path) = try PatternParser().parse(patternString: patternString)
        self.linkSource = linkSource
        self.path = path
    }

    public enum ParsingError: Error {
        case invalidURL
        case unknownError
    }

    struct PatternParser {
        func parse(patternString: String) throws -> (LinkSource?, Path) {
            let linkSource = try guessLinkSource(from: patternString)
            let path = try parsePath(patternString: patternString, linkSource: linkSource)
            return (linkSource, path)
        }

        private func guessLinkSource(from patternString: String) throws -> LinkSource? {
            if patternString.hasPrefix("http://") || patternString.hasPrefix("https://") {
                let bits = patternString.split(separator: "/").droppedSlashElement()
                var components = URLComponents()
                components.scheme = bits.first?.replacingOccurrences(of: ":", with: "") // drop trailing :
                components.host = bits[1]
                guard let url = components.url else {
                    throw ParsingError.invalidURL
                }
                return .universalLink(url)
            } else if let firstColonIndex = patternString.firstIndex(of: ":") {
                let scheme = patternString[patternString.startIndex..<firstColonIndex]
                return .urlScheme(String(scheme))
            } else {
                return nil
            }
        }

        private func parsePath(patternString: String, linkSource: LinkSource?) throws -> Path {
            switch linkSource {
            case .urlScheme(let scheme):
                let pathString = patternString.replacingOccurrences(of: "\(scheme)://", with: "")
                let components = pathString.split(separator: "/").droppedSlashElement()
                return Path(components: components)
            case .universalLink(let url):
                let pathString = patternString.replacingOccurrences(of: url.absoluteString, with: "")
                let components = pathString.split(separator: "/").droppedSlashElement()
                return Path(components: components)
            case .none:
                let components = patternString.split(separator: "/").droppedSlashElement()
                return Path(components: components)
            }
        }
    }
}
