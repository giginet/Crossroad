#if os(iOS)
import UIKit
import XCTest
@testable import Crossroad

final class OpenURLOptionTests: XCTestCase {
    let options: OpenURLOption = {
        let options: [UIApplication.OpenURLOptionsKey: Any] = [
            .sourceApplication: "org.giginet.myapp",
            .openInPlace: true,
        ]
        return OpenURLOption(options: options)
    }()
    func testInit() {
        XCTAssertEqual(options.sourceApplication, "org.giginet.myapp")
        XCTAssertNil(options.annotation)
        XCTAssertEqual(options.openInPlace, true)
    }

    func testContextWithOpenURLOption() {
        let context = Context<OpenURLOption>(url: URL(string: "https://example.com")!,
                                             arguments: .init([:]),
                                             queryParameters: .init([]),
                                             userInfo: options)
        XCTAssertEqual(context.options.sourceApplication, "org.giginet.myapp")
    }
}

#endif
