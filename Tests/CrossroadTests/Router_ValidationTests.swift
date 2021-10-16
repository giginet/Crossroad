import Foundation
import XCTest
import Crossroad

final class Router_ValidationTests: XCTestCase {
    private let customURLScheme: LinkSource = .customURLScheme("pokedex")
    private let universalLink: LinkSource = .universalLink(URL(string: "https://my-awesome-pokedex.com")!)
    private let unknownCustomURLScheme: LinkSource = .customURLScheme("unknown")

    func testValidateForInvalidPattern() throws {
        XCTAssertThrowsError(
            try SimpleRouter(accepts: [self.customURLScheme, self.universalLink]) { route in
                route("invalid://") { _ in
                    return true
                }
            }
        ) { error in
            let error = error as! LocalizedError
            XCTAssertEqual(error.errorDescription, ###"Pattern string 'invalid://' is invalid."###)
        }
    }

    func testValidateForUnknownLinkSource() throws {
        XCTAssertThrowsError(
            try SimpleRouter(accepts: [self.customURLScheme, self.universalLink]) { route in
                route("/hoge/fuga", accepts: .onlyFor(unknownCustomURLScheme)) { _ in
                    return true
                }
            }
        ) { error in
            let error = error as! LocalizedError
            XCTAssertEqual(error.errorDescription, ###"Unknown link sources [unknown://] is registered"###)
        }
    }

    func testValidateForDuplicatedRoute() throws {
        XCTAssertThrowsError(
            try SimpleRouter(accepts: [self.customURLScheme, self.universalLink]) { route in
                route("/hoge/fuga") { _ in
                    return true
                }

                route("/hoge/fuga") { _ in
                    return true
                }
            }
        ) { error in
            let error = error as! LocalizedError
            XCTAssertEqual(error.errorDescription, ###"Route definition for /hoge/fuga (accepts any) is duplicated"###)
        }
    }

    func testValidateForDuplicatedRouteWithAcceptPolicy() throws {
        XCTAssertThrowsError(
            try SimpleRouter(accepts: [self.customURLScheme, self.universalLink]) { route in
                route("/hoge/fuga", accepts: .onlyFor(customURLScheme)) { _ in
                    return true
                }

                route("/hoge/fuga", accepts: .onlyFor(customURLScheme)) { _ in
                    return true
                }
            }
        ) { error in
            let error = error as! LocalizedError
            XCTAssertEqual(error.errorDescription, ###"Route definition for /hoge/fuga (accepts onlyFor(pokedex://)) is duplicated"###)
        }
    }
}
