#if os(iOS)
import UIKit
import XCTest
import Crossroad

final class OpenURLOptionTests: XCTestCase {
    func testInit() {
        let options: [UIApplication.OpenURLOptionsKey: Any] = [
            .sourceApplication: "org.giginet.myapp",
            .openInPlace: true,
        ]
        let option = OpenURLOption(options: options)
        XCTAssertEqual(option.sourceApplication, "org.giginet.myapp")
        XCTAssertNil(option.annotation)
        XCTAssertEqual(option.openInPlace, true)
    }
}

#endif
