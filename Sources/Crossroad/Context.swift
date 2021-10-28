import Foundation

struct Arguments {
    enum Error: Swift.Error {
        case keyNotFound(String)
        case couldNotParse(Parsable.Type)
    }
    typealias Storage = [String: String]

    init(_ storage: [String: String]) {
        self.storage = storage
    }

    fileprivate func get<T>(for key: String) throws -> T where T: Parsable {
        if let argument = storage[key] {
            if let value = T(from: argument) {
                return value
            }
            throw Error.couldNotParse(T.self)
        }
        throw Error.keyNotFound(key)
    }

    private var storage: [String: String]
}

@dynamicMemberLookup
public struct QueryParameters {
    typealias Storage = [URLQueryItem]

    init(_ storage: [URLQueryItem]) {
        self.storage = storage
    }

    fileprivate func get<T>(for key: String) -> T? where T: Parsable {
        if let queryItem = queryItem(from: key) {
            if let queryValue = queryItem.value,
               let value = T(from: queryValue) {
                return value
            }
        }
        return nil
    }

    public subscript<T: Parsable>(dynamicMember key: String) -> T? {
        return get(for: key)
    }

    private func queryItem(from key: String) -> URLQueryItem? {
        func isEqual(_ lhs: String, _ rhs: String) -> Bool {
            return lhs.lowercased() == rhs.lowercased()
        }
        return storage.first { isEqual($0.name, key) }
    }

    fileprivate func queryItem(matchesIn regexp: NSRegularExpression) -> URLQueryItem? {
        return storage.first { item in
            return !regexp.matches(in: item.name,
                                   options: [],
                                   range: NSRange(location: 0, length: item.name.utf16.count)).isEmpty
        }
    }

    private var storage: [URLQueryItem]
}

public struct Context<UserInfo> {
    public let url: URL
    private let arguments: Arguments
    public let queryParameters: QueryParameters
    public let userInfo: UserInfo

    internal init(url: URL, arguments: Arguments, queryParameters: QueryParameters, userInfo: UserInfo) {
        self.url = url
        self.arguments = arguments
        self.queryParameters = queryParameters
        self.userInfo = userInfo
    }

    @available(*, deprecated, message: "subscript for an argument is depricated.", renamed: "argument(for:)")
    public subscript<T: Parsable>(argument keyword: String) -> T? {
        return try? arguments.get(for: keyword)
    }

    @available(*, deprecated, renamed: "subscript(queryParameter:)")
    public subscript<T: Parsable>(parameter key: String) -> T? {
        return queryParameter(for: key, as: T.self)
    }

    public subscript<T: Parsable>(queryParameter key: String) -> T? {
        return queryParameters.get(for: key)
    }

    public func argument<T: Parsable>(for key: String, as type: T.Type = T.self) throws -> T {
        return try arguments.get(for: key)
    }

    @available(*, deprecated, renamed: "queryParameter(for:)")
    public func parameter<T: Parsable>(for key: String, as type: T.Type = T.self) -> T? {
        return queryParameter(for: key, as: type)
    }

    public func queryParameter<T: Parsable>(for key: String, as type: T.Type = T.self) -> T? {
        return queryParameters.get(for: key)
    }

    public func parameter<T: Parsable>(matchesIn regexp: NSRegularExpression) -> T? {
        return queryParameter(matchesIn: regexp)
    }

    public func queryParameter<T: Parsable>(matchesIn regexp: NSRegularExpression) -> T? {
        if let queryItem = queryParameters.queryItem(matchesIn: regexp) {
            if let queryValue = queryItem.value,
               let value = T(from: queryValue) {
                return value
            }
        }
        return nil
    }
}

extension Context where UserInfo == Void {
    init(url: URL, arguments: Arguments, queryParameters: QueryParameters) {
        self.init(url: url, arguments: arguments, queryParameters: queryParameters, userInfo: ())
    }
}
