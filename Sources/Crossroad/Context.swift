import Foundation

public struct Arguments {
    enum Error: Swift.Error {
        case keyNotFound(String)
        case couldNotParse(Parsable.Type)
    }
    typealias Storage = [String: String]

    init(_ storage: [String: String]) {
        self.storage = storage
    }

    fileprivate func get<T>(named key: String) throws -> T where T: Parsable {
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

    public enum Error: Swift.Error {
        case missingRequiredQueryParameter(String)
    }

    init(_ storage: [URLQueryItem]) {
        self.storage = storage
    }

    fileprivate func get<T>(named key: String) -> T? where T: Parsable {
        if let queryItem = queryItem(from: key) {
            if let queryValue = queryItem.value,
               let value = T(from: queryValue) {
                return value
            }
        }
        return nil
    }

    public subscript<T: Parsable>(dynamicMember key: String) -> T? {
        return get(named: key)
    }

    public subscript<T: Parsable>(_ key: String) -> T? {
        return get(named: key)
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

public protocol ContextProtocol {
    var url: URL { get }
    /// This struct is for internal usage.
    var internalArgumentsContainer: Arguments { get }
    var queryParameters: QueryParameters { get }
}

extension ContextProtocol {
    func attach<UserInfo>(_ userInfo: UserInfo) -> Context<UserInfo> {
        Context<UserInfo>(url: url, internalArgumentsContainer: internalArgumentsContainer, queryParameters: queryParameters, userInfo: userInfo)
    }
}

struct AbstractContext: ContextProtocol {
    let url: URL
    let internalArgumentsContainer: Arguments
    let queryParameters: QueryParameters

    init(url: URL, arguments: Arguments, queryParameters: QueryParameters) {
        self.url = url
        self.internalArgumentsContainer = arguments
        self.queryParameters = queryParameters
    }
}

public struct Context<UserInfo>: ContextProtocol {
    public let url: URL
    public let internalArgumentsContainer: Arguments
    public let queryParameters: QueryParameters
    public let userInfo: UserInfo

    internal init(url: URL, internalArgumentsContainer: Arguments, queryParameters: QueryParameters, userInfo: UserInfo) {
        self.url = url
        self.internalArgumentsContainer = internalArgumentsContainer
        self.queryParameters = queryParameters
        self.userInfo = userInfo
    }
}

extension ContextProtocol {
    @available(*, deprecated, message: "subscript for an argument is depricated.", renamed: "argument(named:)")
    public subscript<T: Parsable>(argument keyword: String) -> T? {
        return try? internalArgumentsContainer.get(named: keyword)
    }

    @available(*, deprecated, message: "Use queryParameters[key] instead")
    public subscript<T: Parsable>(parameter key: String) -> T? {
        return queryParameter(named: key)
    }

    public func argument<T: Parsable>(named key: String, as type: T.Type = T.self) throws -> T {
        return try internalArgumentsContainer.get(named: key)
    }

    @available(*, deprecated, renamed: "queryParameter(named:)")
    public func parameter<T: Parsable>(for key: String, as type: T.Type = T.self) -> T? {
        return queryParameter(named: key)
    }

    public func queryParameter<T: Parsable>(named key: String) -> T? {
        return queryParameters.get(named: key)
    }

    public func requiredQueryParameter<T: Parsable>(named key: String, as type: T.Type = T.self) throws -> T {
        guard let queryParameter: T = queryParameters.get(named: key) else {
            throw QueryParameters.Error.missingRequiredQueryParameter(key)
        }
        return queryParameter
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
        self.init(url: url, internalArgumentsContainer: arguments, queryParameters: queryParameters, userInfo: ())
    }
}
