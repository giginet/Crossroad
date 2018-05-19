import Foundation
import UIKit

typealias ApplicationOpenURLOptions = [UIApplicationOpenURLOptionsKey: Any]

// https://developer.apple.com/documentation/uikit/uiapplicationopenurloptionskey
public struct OpenURLOption {
    let sourceApplication: String?
    let annotation: UIDocumentInteractionController?
    let openInPlace: Bool

    init(options: ApplicationOpenURLOptions) {
        self.sourceApplication = options[.sourceApplication] as? String
        self.annotation = options[.annotation] as? UIDocumentInteractionController
        self.openInPlace = options[.openInPlace] as? Bool ?? false
    }
}

public typealias DefaultRouter = Router<OpenURLOption>

extension Router where UserInfo == OpenURLOption {
    func openIfPossible(_ url: URL, options: ApplicationOpenURLOptions) -> Bool {
        return openIfPossible(url, userInfo: OpenURLOption(options: options))
    }

    func responds(to url: URL, options: ApplicationOpenURLOptions) -> Bool {
        return responds(to: url, userInfo: OpenURLOption(options: options))
    }
}
