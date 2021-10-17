import Foundation
import XCTest
import Crossroad

final class Router_AcceptanceTests: XCTestCase {
    private let customURLScheme: LinkSource = .customURLScheme("pokedex")
    private let universalLink: LinkSource = .universalLink(URL(string: "https://my-awesome-pokedex.com")!)

    func testAcceptOnly() throws {
        let router = try SimpleRouter(accepts: [customURLScheme, universalLink]) { route in
            route("/pokemons/:id", accepts: .only(for: universalLink)) { _ in
                return true
            }
        }

        XCTAssertFalse(router.responds(to: URL(string: "pokedex://pokemons/:id")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://my-awesome-pokedex.com/pokemons/:id")!))
    }
}
