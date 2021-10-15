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
    public let linkSource: LinkSource
    public let path: Path
    
    public init(linkSource: LinkSource, path: Path) {
        self.linkSource = linkSource
        self.path = path
    }
}
