import Foundation
import UIKit

public typealias ApplicationOpenURLOptions = [UIApplicationOpenURLOptionsKey: Any]

// https://developer.apple.com/documentation/uikit/uiapplicationopenurloptionskey
public struct OpenURLOption {
    public let sourceApplication: String?
    public let annotation: UIDocumentInteractionController?
    public let openInPlace: Bool

    public init(options: ApplicationOpenURLOptions) {
        self.sourceApplication = options[.sourceApplication] as? String
        self.annotation = options[.annotation] as? UIDocumentInteractionController
        self.openInPlace = options[.openInPlace] as? Bool ?? false
    }
}

public typealias DefaultRouter = Router<OpenURLOption>

public extension Router where UserInfo == OpenURLOption {
    public func openIfPossible(_ url: URL, options: ApplicationOpenURLOptions) -> Bool {
        return openIfPossible(url, userInfo: OpenURLOption(options: options))
    }

    public func responds(to url: URL, options: ApplicationOpenURLOptions) -> Bool {
        return responds(to: url, userInfo: OpenURLOption(options: options))
    }
}
