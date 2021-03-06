import Foundation

// A ':' in the host name is not a valid URL (as : is for the port) so we cannot use Foundation's URL for the pattern and have to parse it ourselves.
// Note that it's very simple and do not allow complicated patterns with for example queries.
internal protocol PatternURL {
    func match(_: URL) -> Bool
    var pathComponent: [String] { get }
}

struct RelativePatternURL: PatternURL {
    let pathComponent: [String]
    
    init(pathComponent: [String]) {
        self.pathComponent = pathComponent
    }
    
    init(path: String) {
        let components = path.components(separatedBy: "/")
        self.init(pathComponent: Array(components[1...]))
    }
    
    func match(_ url: URL) -> Bool {
        return true
    }
}

struct AbsolutePatternURL: PatternURL {
    static let keywordPrefix = ":"
    
    let pathComponent: [String]
    private let prefix: Prefix
    
    init(prefix: Prefix, pathComponent: [String]) {
        self.prefix = prefix
        self.pathComponent = pathComponent
    }
    
    init(prefix: Prefix, path: String) {
        let components = path.components(separatedBy: "/")
        self.init(prefix: prefix, pathComponent: Array(components[1...]))
    }
    
    func match(_ url: URL) -> Bool {
        return true
    }
}

func buildPatternURL(patternURLString: String) -> PatternURL? {
    if patternURLString.hasPrefix("/") {
        return RelativePatternURL(path: patternURLString)
    } else {
        let bits = patternURLString.components(separatedBy: "://")
        guard let scheme = bits.first, let path = bits.last, bits.count == 2 else {
            return nil
        }
        return AbsolutePatternURL(prefix: .scheme(scheme), path: path)
    }
}
