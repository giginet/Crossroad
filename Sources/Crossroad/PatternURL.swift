import Foundation

// A ':' in the host name is not a valid URL (as : is for the port) so we cannot use Foundation's URL for the pattern and have to parse it ourselves.
// Note that it's very simple and do not allow complicated patterns with for example queries.
internal struct PatternURL {
    enum PathType {
        case relative
        case absolute(scheme: String, host: String)
    }
    static let keywordPrefix = ":"
    let pathComponents: [String]
    let patternString: String
    let pathType: PathType

    private static let schemeSeparator = "://"
    private static let pathSeparator = "/"
    
    init?(string: String) {
        let components: [String]
        if string.first == "/" {
            self.pathType = .relative
            components = string.components(separatedBy: PatternURL.pathSeparator)
        } else {
            let firstSplit = string.components(separatedBy: PatternURL.schemeSeparator)
            guard let scheme = firstSplit.first, !scheme.isEmpty else {
                return nil
            }
            let rest = firstSplit[1 ..< firstSplit.count].joined(separator: PatternURL.schemeSeparator)
            components = rest.components(separatedBy: PatternURL.pathSeparator)
            guard let host = components.first, !host.isEmpty else {
                return nil
            }
            self.pathType = .absolute(scheme: scheme, host: host)
        }
        
        self.patternString = string
        if components.count > 1 {
            let left = components[1 ..< components.count]
            // In URL, pathComponents includes the starting "/" so do the same.
            if left.count == 1 && left.first == "" {
                // URL with just a starting "/"
                pathComponents = [PatternURL.pathSeparator]
            } else {
                pathComponents = [PatternURL.pathSeparator] + components[1 ..< components.count]
            }
        } else {
            pathComponents = []
        }
    }

    func hasPrefix(url: URL) -> Bool {
        return patternString.hasPrefix(url.absoluteString)
    }
}
