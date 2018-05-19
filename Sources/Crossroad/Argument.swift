import Foundation

public protocol Argument {
    init?(string: String)
}

extension Int: Argument {
    public init?(string: String) {
        if let value = Int(string) {
            self = value
        } else {
            return nil
        }
    }
}

extension Int64: Argument {
    public init?(string: String) {
        if let value = Int64(string) {
            self = value
        } else {
            return nil
        }
    }
}

extension String: Argument {
    public init?(string: String) {
        self = string
    }
}

extension URL: Argument { }

public extension RawRepresentable where Self: Argument, Self.RawValue == String {
    public init?(string: String) {
        self.init(rawValue: string)
    }
}
