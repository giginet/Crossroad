import Foundation

public typealias Arguments = [String: String]
public typealias Parameters = [URLQueryItem]

public struct Context<UserInfo> {
    public enum Error: Swift.Error {
        case parsingArgumentFailed
    }

    public let url: URL
    private let arguments: Arguments
    private let parameters: Parameters
    public let userInfo: UserInfo

    internal init(url: URL, arguments: Arguments, parameters: Parameters, userInfo: UserInfo) {
        self.url = url
        self.arguments = arguments
        self.parameters = parameters
        self.userInfo = userInfo
    }

    public subscript<T: Parsable>(argument keyword: String) -> T? {
        return try? argument(for: keyword)
    }

    public subscript<T: Parsable>(parameter key: String) -> T? {
        return parameter(for: key)
    }

    public func argument<T: Parsable>(for key: String) throws -> T {
        if let argument = arguments[key] {
            if let value = T(from: argument) {
                return value
            }
        }
        throw Error.parsingArgumentFailed
    }

    public func parameter<T: Parsable>(for key: String) -> T? {
        if let queryItem = queryItem(from: key) {
            if let queryValue = queryItem.value,
                let value = T(from: queryValue) {
                return value
            }
        }
        return nil
    }

    public func parameter<T: Parsable>(matchesIn regexp: NSRegularExpression) -> T? {
        if let queryItem = queryItem(matchesIn: regexp) {
            if let queryValue = queryItem.value,
                let value = T(from: queryValue) {
                return value
            }
        }
        return nil
    }

    private func queryItem(from key: String) -> URLQueryItem? {
        func isEqual(_ lhs: String, _ rhs: String) -> Bool {
            return lhs.lowercased() == rhs.lowercased()
        }
        return parameters.first { isEqual($0.name, key) }
    }

    private func queryItem(matchesIn regexp: NSRegularExpression) -> URLQueryItem? {
        return parameters.first { item in
            return !regexp.matches(in: item.name,
                                   options: [],
                                   range: NSRange(location: 0, length: item.name.utf16.count)).isEmpty
        }
    }
}
