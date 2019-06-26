import Foundation

// A ':' in the host name is not a valid URL (as : is for the port) so we cannot use Foundation's URL for the pattern and have to parse it ourselves.
// Note that it's very simple and do not allow complicated patterns with for example queries.
internal struct PatternURL {
    static let keywordPrefix = ":"

    let scheme: String
    let host: String
    let pathComponents: [String]
    let patternString: String

    private static let schemeSeparator = "://"
    private static let pathSeparator = "/"

    init?(string: String) {
        let firstSplit = string.components(separatedBy: PatternURL.schemeSeparator)
        guard let scheme = firstSplit.first, !scheme.isEmpty else {
            return nil
        }
        let rest = firstSplit[1 ..< firstSplit.count].joined(separator: PatternURL.schemeSeparator)
        let components = rest.components(separatedBy: PatternURL.pathSeparator)
        guard let host = components.first, !host.isEmpty else {
            return nil
        }
        self.scheme = scheme
        self.host = host
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
