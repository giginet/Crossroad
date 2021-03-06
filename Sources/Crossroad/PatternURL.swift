import Foundation

// A ':' in the host name is not a valid URL (as : is for the port) so we cannot use Foundation's URL for the pattern and have to parse it ourselves.
// Note that it's very simple and do not allow complicated patterns with for example queries.
internal protocol PatternURL {
    func hasPrefix(_: URL) -> Bool
    var host: String { get }
    var pathComponents: [String] { get }
}

struct RelativePatternURL: PatternURL {
    let host: String
    let pathComponents: [String]
    
    init(host: String, pathComponents: [String]) {
        self.host = host
        self.pathComponents = pathComponents
    }
    
    func hasPrefix(_ url: URL) -> Bool {
        return true
    }
}

struct AbsolutePatternURL: PatternURL {
    static let keywordPrefix = ":"
    
    let prefix: Prefix
    let host: String
    let pathComponents: [String]
    
    init(scheme: String, host: String, pathComponents: [String]) {
        self.prefix = .scheme(scheme)
        self.host = host
        self.pathComponents = pathComponents
    }
    
    init?(url: URL, pathComponents: [String]) {
        self.prefix = .url(url)
        guard let host = url.host else {
            return nil
        }
        self.host = host
        self.pathComponents = pathComponents
    }
    
    func hasPrefix(_ url: URL) -> Bool {
        switch prefix {
        case .scheme(let patternScheme):
            return url.scheme?.lowercased() == patternScheme.lowercased()
        case .url(let patternURL):
            return url.absoluteString.lowercased().hasPrefix(patternURL.absoluteString.lowercased())
        }
    }
}

private let pathSeparator = "/"

func buildPatternURL(patternURLString: String) -> PatternURL? {
    if patternURLString.hasPrefix(pathSeparator) {
        let hostAndComponents = patternURLString.components(separatedBy: pathSeparator).dropFirst()
        
        guard let host = hostAndComponents.first else {
            return nil
        }
        let remainings = hostAndComponents.dropFirst()
        let pathComponents: [String] = [pathSeparator] + remainings
        
        return RelativePatternURL(host: host, pathComponents: pathComponents)
    } else {
        let bits = patternURLString.components(separatedBy: "://")
        guard let scheme = bits.first, let path = bits.last, bits.count == 2 else {
            return nil
        }
        let hostAndComponents = path.components(separatedBy: pathSeparator)
        
        guard let host = hostAndComponents.first else {
            return nil
        }
        let remainings = hostAndComponents.dropFirst()
        let pathComponents: [String]
        if remainings.isEmpty {
            pathComponents = Array(remainings)
        } else {
            pathComponents = [pathSeparator] + remainings
        }
        
        return AbsolutePatternURL(scheme: scheme, host: host, pathComponents: pathComponents)
    }
}
