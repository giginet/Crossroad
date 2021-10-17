import Foundation

public struct Arguments {
    public enum Error: Swift.Error {
        case keyNotFound(String)
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
        }
        throw Error.keyNotFound(key)
    }

    private var storage: [String: String]
}

@dynamicMemberLookup
public struct Parameters {
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
    public let parameters: Parameters
    public let userInfo: UserInfo

    internal init(url: URL, arguments: Arguments, parameters: Parameters, userInfo: UserInfo) {
        self.url = url
        self.arguments = arguments
        self.parameters = parameters
        self.userInfo = userInfo
    }

    @available(*, deprecated, message: "subscript for an argument is depricated.", renamed: "argument(for:)")
    public subscript<T: Parsable>(argument keyword: String) -> T? {
        return try? arguments.get(for: keyword)
    }

    public subscript<T: Parsable>(parameter key: String) -> T? {
        return parameters.get(for: key)
    }

    public func argument<T: Parsable>(for key: String) throws -> T {
        return try arguments.get(for: key)
    }

    public func parameter<T: Parsable>(for key: String) -> T? {
        return parameters.get(for: key)
    }

    public func parameter<T: Parsable>(matchesIn regexp: NSRegularExpression) -> T? {
        if let queryItem = parameters.queryItem(matchesIn: regexp) {
            if let queryValue = queryItem.value,
               let value = T(from: queryValue) {
                return value
            }
        }
        return nil
    }
}

extension Context where UserInfo == Void {
    init(url: URL, arguments: Arguments, parameters: Parameters) {
        self.init(url: url, arguments: arguments, parameters: parameters, userInfo: ())
    }

    func attached<T>(_ userInfo: T) -> Context<T> {
        Context<T>(url: url,
                   arguments: arguments,
                   parameters: parameters,
                   userInfo: userInfo)
    }
}
