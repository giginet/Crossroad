import Foundation

@dynamicMemberLookup
public struct Argument {
    public enum Error: Swift.Error {
        case parsingArgumentFailed
    }
    private let arguments: [String: String]

    fileprivate init(_ arguments: [String: String]) {
        self.arguments = arguments
    }

    public func fetch<T: Extractable>(for key: String) throws -> T {
        if let argument = arguments[key] {
            if let value = T.extract(from: argument) {
                return value
            }
        }
        throw Error.parsingArgumentFailed
    }

    public subscript<T: Extractable>(dynamicMember member: String) -> T? {
        return try? fetch(for: member)
    }
}

@dynamicMemberLookup
public struct Parameter {
    private let parameters: [URLQueryItem]

    fileprivate init(_ parameters: [URLQueryItem]) {
        self.parameters = parameters
    }

    public subscript<T: Extractable>(dynamicMember member: String) -> T? {
        return fetch(for: member)
    }

    public func fetch<T: Extractable>(for key: String, caseInsensitive: Bool = false) -> T? {
        if let queryItem = queryItem(from: key, caseInsensitive: caseInsensitive) {
            if let queryValue = queryItem.value,
                let value = T.extract(from: queryValue) {
                return value
            }
        }
        return nil
    }

    public func fetch<T: Extractable>(matchesIn regexp: NSRegularExpression) -> T? {
        if let queryItem = queryItem(matchesIn: regexp) {
            if let queryValue = queryItem.value,
                let value = T.extract(from: queryValue) {
                return value
            }
        }
        return nil
    }

    private func queryItem(from key: String, caseInsensitive: Bool) -> URLQueryItem? {
        func isEqual(_ lhs: String, _ rhs: String, caseInsensitive: Bool) -> Bool {
            if caseInsensitive {
                return lhs.lowercased() == rhs.lowercased()
            } else {
                return lhs == rhs
            }
        }
        return parameters.first { isEqual($0.name, key, caseInsensitive: caseInsensitive) }
    }

    private func queryItem(matchesIn regexp: NSRegularExpression) -> URLQueryItem? {
        return parameters.first { item in
            return !regexp.matches(in: item.name,
                                   options: [],
                                   range: NSRange(location: 0, length: item.name.utf16.count)).isEmpty
        }
    }
}

public struct Context<UserInfo> {
    public let url: URL
    public let userInfo: UserInfo
    public let arguments: Argument
    public let parameters: Parameter

    internal init(url: URL, arguments: [String: String],
                  parameters: [URLQueryItem],
                  userInfo: UserInfo) {
        self.url = url
        self.userInfo = userInfo
        self.arguments = Argument(arguments)
        self.parameters = Parameter(parameters)
    }
}
