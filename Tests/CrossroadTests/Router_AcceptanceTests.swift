import Foundation
import XCTest
import Crossroad

final class Router_AcceptanceTests: XCTestCase {
    private let customURLScheme: LinkSource = .urlScheme("pokedex")
    private let universalLink: LinkSource = .universalLink(URL(string: "https://my-awesome-pokedex.com")!)

    func testAcceptOnly() throws {
        typealias Route = SimpleRouter.Route
        let router = try SimpleRouter(accepts: [customURLScheme, universalLink]) {
            Route("/pokemons/:id", accepts: .onlyFor(universalLink)) { _ in
                return true
            }
        }

        XCTAssertFalse(router.responds(to: URL(string: "pokedex://pokemons/:id")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://my-awesome-pokedex.com/pokemons/:id")!))
    }
}
