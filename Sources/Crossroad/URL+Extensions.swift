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
}
