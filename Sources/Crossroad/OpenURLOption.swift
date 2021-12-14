#if os(iOS)

import Foundation
import UIKit

public typealias ApplicationOpenURLOptions = [UIApplication.OpenURLOptionsKey: Any]

// https://developer.apple.com/documentation/uikit/uiapplicationopenurloptionskey
public struct OpenURLOption {
    public let sourceApplication: String?
    public let annotation: Any?
    public let openInPlace: Bool

    public init(options: ApplicationOpenURLOptions) {
        self.sourceApplication = options[.sourceApplication] as? String
        self.annotation = options[.annotation]
        self.openInPlace = options[.openInPlace] as? Bool ?? false
    }

    @available(iOS 13.0, *)
    public init(options: UIScene.OpenURLOptions) {
        self.sourceApplication = options.sourceApplication
        self.annotation = options.annotation
        self.openInPlace = options.openInPlace
    }
}

public typealias DefaultRouter = Router<OpenURLOption>

public extension Router where UserInfo == OpenURLOption {
    @discardableResult
    func openIfPossible(_ url: URL, options: ApplicationOpenURLOptions) async -> Bool {
        return await openIfPossible(url, userInfo: OpenURLOption(options: options))
    }
}

extension Router where UserInfo == OpenURLOption {
    @discardableResult
    public func openIfPossible(_ url: URL, options: UIScene.OpenURLOptions) async -> Bool {
        return await openIfPossible(url, userInfo: OpenURLOption(options: options))
    }
}

extension Context where UserInfo == OpenURLOption {
    public var options: OpenURLOption {
        userInfo
    }
}

#endif
