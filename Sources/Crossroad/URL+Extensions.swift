import Foundation

extension URL {
    var absoluteStringWithoutScheme: String {
        if let scheme = scheme {
            let indexOfStartPath = absoluteString.index(absoluteString.startIndex,
                                                        offsetBy: scheme.count + "://".count)
            return String(absoluteString[indexOfStartPath...])
        } else {
            return absoluteString
        }
    }
    
    var componentsWithHost: [String] {
        let hosts = [host].compactMap { $0 }
        if pathComponents.isEmpty {
            return hosts
        } else {
            let components = pathComponents[1...]
            return hosts + components
        }
    }
}
