import Foundation
import XCTest
import UIKit
import Crossroad

final class OpenURLOptionTests: XCTestCase {
    func testInit() {
        let options: [UIApplicationOpenURLOptionsKey: Any] = [
            .sourceApplication: "org.giginet.myapp",
            .openInPlace: true,
        ]
        let option = OpenURLOption(options: options)
        XCTAssertEqual(option.sourceApplication, "org.giginet.myapp")
        XCTAssertNil(option.annotation)
        XCTAssertEqual(option.openInPlace, true)
    }
}
