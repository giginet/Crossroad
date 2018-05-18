import Foundation

public typealias Arguments = [String: String]
public typealias Parameters = [URLQueryItem]

public struct Context<UserInfo> {
    enum Error: Swift.Error {
        case parsingArgumentFailed
    }

    public let url: URL
    private let arguments: Arguments
    private let parameters: Parameters
    public let userInfo: UserInfo?

    internal init(url: URL, arguments: Arguments, parameters: Parameters, userInfo: UserInfo? = nil) {
        self.url = url
        self.arguments = arguments
        self.parameters = parameters
        self.userInfo = userInfo
    }

    public func argument<T: Argument>(for key: String) throws -> T {
        if let argument = arguments[key] {
            if let value = T(string: argument) {
                return value
            }
        }
        throw Error.parsingArgumentFailed
    }

    public func parameter<T: Argument>(for key: String) -> T? {
        if let queryItem = self.queryItem(from: key) {
            if let queryValue = queryItem.value,
                let value = T(string: queryValue) {
                return value
            }
        }
        return nil
    }

    private func queryItem(from key: String) -> URLQueryItem? {
        return parameters.first { $0.name == key }
    }
}
