import Foundation

public enum Source: Hashable {
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
}

public struct Pattern: Hashable {
    public let source: Source
    public let path: Path
    
    public init(source: Source, path: Path) {
        self.source = source
        self.path = path
    }
}
