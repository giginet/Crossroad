import Foundation

@available(*, deprecated, renamed: "Parsable")
public protocol Extractable {
    @available(*, deprecated, renamed: "init(from:)")
    static func extract(from: String) -> Self?
}

public protocol Parsable {
    init?(from: String)
}

private extension Parsable {
    init?(_ string: String, conversion: (String) -> Self?) {
        guard let value = conversion(string) else {
            return nil
        }
        self = value
    }
}

extension Int: Parsable {
    public init?(from string: String) {
        self.init(string, conversion: Int.init(_:))
    }
}

extension Int64: Parsable {
    public init?(from string: String) {
        self.init(string, conversion: Int64.init(_:))
    }
}

extension Float: Parsable {
    public init?(from string: String) {
        self.init(string, conversion: Float.init(_:))
    }
}

extension Double: Parsable {
    public init?(from string: String) {
        self.init(string, conversion: Double.init(_:))
    }
}

extension Bool: Parsable {
    public init?(from string: String) {
        self.init(string, conversion: Bool.init(_:))
    }
}

extension String: Parsable {
    public init?(from string: String) {
        self = string
    }
}

extension Array: Parsable where Array.Element: Parsable {
    public init?(from string: String) {
        let components = string.split(separator: ",")
        self = components
            .map { String($0) }
            .compactMap(Element.init(from:))
    }
}

extension URL: Parsable {
    public init?(from string: String) {
        self.init(string, conversion: URL.init(string:))
    }
}

extension RawRepresentable where Self: Parsable, Self.RawValue == String {
    public init?(from string: String) {
        guard let value = Self(rawValue: string) else {
            return nil
        }
        self = value
    }
}
