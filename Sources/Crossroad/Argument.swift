import Foundation

public protocol Argument {
    init?(string: String)
}

extension Int: Argument {
    public init?(string: String) {
        self.init(string)
    }
}

extension Int64: Argument {
    public init?(string: String) {
        self.init(string)
    }
}

extension Float: Argument {
    public init?(string: String) {
        self.init(string)
    }
}

extension Double: Argument {
    public init?(string: String) {
        self.init(string)
    }
}

extension Bool: Argument {
    public init?(string: String) {
        self.init(string)
    }
}

extension String: Argument {
    public init?(string: String) {
        self = string
    }
}

extension Array: Argument where Array.Element: Argument {
    public init?(string: String) {
        let components = string.split(separator: ",")
        self = components
            .map { String($0) }
            .compactMap(Element.init(string:))
    }
}

extension URL: Argument { }

public extension RawRepresentable where Self: Argument, Self.RawValue == String {
    public init?(string: String) {
        self.init(rawValue: string)
    }
}
