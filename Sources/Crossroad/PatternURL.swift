import Foundation

// A ':' in the host name is not a valid URL (as : is for the port) so we cannot use Foundation's URL for the pattern and have to parse it ourselves.
// Note that it's very simple and do not allow complicated patterns with for example queries.
internal struct PatternURL {
    static let keywordPrefix = ":"
    
    enum Prefix: Hashable {
        case scheme(String)
        case url(URL)
    }
    
    enum MatchingPattern {
        case specified(Prefix)
        case any
    }

    let matchingPattern: MatchingPattern
    let pathComponents: [String]

    private static let schemeSeparator = "://"
    private static let pathSeparator = "/"

    init(matchingPattern: MatchingPattern, path: String) {
        self.matchingPattern = matchingPattern
        pathComponents = path.components(separatedBy: Self.pathSeparator)
    }

    func hasPrefix(url: URL) -> Bool {
        switch matchingPattern {
        case .any:
            return true
        case .specified(let prefix):
            return true
        }
    }
}
