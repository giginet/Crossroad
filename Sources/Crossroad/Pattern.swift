import Foundation

public enum LinkSource: Hashable, CustomStringConvertible {
    case customURLScheme(String)
    case universalLink(URL)

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .customURLScheme(let scheme):
            hasher.combine(scheme)
        case .universalLink(let url):
            hasher.combine(url)
        }
    }

    public var description: String {
        switch self {
        case .customURLScheme(let scheme):
            return "\(scheme)://"
        case .universalLink(let url):
            return url.absoluteString
        }
    }
}

struct Path: Hashable, CustomStringConvertible {
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

    public var description: String {
        "/" + components.joined(separator: "/")
    }
}

extension Path: ExpressibleByStringLiteral {
    typealias StringLiteralType = String

    init(stringLiteral value: String) {
        self.init(pathString: value)
    }

    init(unicodeScalarLiteral value: String) {
        self.init(pathString: value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(pathString: value)
    }
}

struct Pattern: Hashable {
    let linkSource: LinkSource?
    let path: Path

    init(linkSource: LinkSource?, path: Path) {
        self.linkSource = linkSource
        self.path = path
    }

    init(patternString: String) throws {
        let (linkSource, path) = try PatternParser().parse(patternString: patternString)
        self.linkSource = linkSource
        self.path = path
    }

    var absoluteString: String {
        switch linkSource {
        case .customURLScheme(let scheme):
            return "\(scheme):/\(path.absoluteString)"
        case .universalLink(let url):
            let concated = path.components.reduce(url, { $0.appendingPathComponent($1) })
            return concated.absoluteString
        case .none:
            return path.absoluteString
        }
    }

    enum ParsingError: LocalizedError {
        case invalidPattern(String)
        case unknownError

        var errorDescription: String? {
            switch self {
            case .invalidPattern(let pattern):
                return "Pattern string '\(pattern)' is invalid."
            case .unknownError:
                return nil
            }
        }
    }

    struct PatternParser {
        func parse(patternString: String) throws -> (LinkSource?, Path) {
            let linkSource = try guessLinkSource(from: patternString)
            let path = try parsePath(patternString: patternString, linkSource: linkSource)
            return (linkSource, path)
        }

        private func containsSchemeSeparator(in string: String) -> String.Index? {
            string.range(of: "://")?.lowerBound
        }

        private func extractScheme(from urlString: String) -> String? {
            guard let index = containsSchemeSeparator(in: urlString) else { return nil }
            return String(urlString[..<index])
        }

        private func guessLinkSource(from patternString: String) throws -> LinkSource? {
            if patternString.hasPrefix("http://") || patternString.hasPrefix("https://") {
                let bits = patternString.split(separator: "/").droppedSlashElement()

                guard let scheme = extractScheme(from: patternString), bits.count >= 2 else {
                    throw ParsingError.invalidPattern(patternString)
                }

                let host = bits[1]

                let beforePathes = "\(scheme)://\(host)"
                guard let url = URL(string: beforePathes) else {
                    throw ParsingError.invalidPattern(patternString)
                }

                let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
                guard let url = components?.url else {
                    throw ParsingError.invalidPattern(patternString)
                }
                return .universalLink(url)
            } else if let firstColonIndex = containsSchemeSeparator(in: patternString) {
                let scheme = patternString[patternString.startIndex..<firstColonIndex]
                return .customURLScheme(String(scheme))
            } else {
                return nil
            }
        }

        private func parsePath(patternString: String, linkSource: LinkSource?) throws -> Path {
            let path: Path
            switch linkSource {
            case .customURLScheme(let scheme):
                let pathString = patternString.replacingOccurrences(of: "\(scheme)://", with: "")
                guard !pathString.contains("//") else {
                    throw ParsingError.invalidPattern(patternString)
                }
                let components = pathString.split(separator: "/").droppedSlashElement()
                path = Path(components: components)
            case .universalLink(let url):
                let pathString = patternString.replacingOccurrences(of: url.absoluteString, with: "")
                guard !pathString.contains("//") else {
                    throw ParsingError.invalidPattern(patternString)
                }
                let components = pathString.split(separator: "/").droppedSlashElement()
                path = Path(components: components)
            case .none:
                guard !patternString.contains("//") else {
                    throw ParsingError.invalidPattern(patternString)
                }
                let components = patternString.split(separator: "/").droppedSlashElement()
                path = Path(components: components)
            }
            return path
        }
    }
}

extension Pattern: CustomStringConvertible {
    public var description: String {
        switch linkSource {
        case .none:
            return "\(path)"
        case .customURLScheme(let scheme):
            return "\(scheme):/\(path)"
        case .universalLink(let universalLink):
            return path.components.reduce(into: universalLink) { url, component in
                url = url.appendingPathComponent(component)
            }.absoluteString
        }
    }
}
