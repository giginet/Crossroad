import Foundation

public typealias Arguments = [String: String]
public typealias Parameters = [URLQueryItem]

public struct Context {
    enum Error: Swift.Error {
        case parsingArgumentFailed
    }

    public let url: URL
    private let arguments: Arguments
    private let parameters: Parameters

    internal init(url: URL, arguments: Arguments, parameters: Parameters) {
        self.url = url
        self.arguments = arguments
        self.parameters = parameters
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
