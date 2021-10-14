import Foundation

struct Matcher {
    var acceptableSources: Set<Source>

    func match(_ url: URL, path: Path) -> ContextProtocol? {
        for source in acceptableSources {
            switch source {
            case .urlScheme(let scheme):
                guard url.scheme == scheme else { return nil }
                let parser = URLParser()
                let context = parser.parse(url, in: "\(scheme)://\(path.absoluteString)")
                return context
            case .universalLink(let baseURL):
                guard url.scheme == baseURL.scheme && url.host == baseURL.host else {
                    return nil
                }
                let parser = URLParser()
                var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
                components.path = path.absoluteString
                let context = parser.parse(url, in: components.url!.absoluteString)
                return context
            }
        }
        return nil
    }
}

// cookpad://:id
// (http|https)://cookpad.com/:id
