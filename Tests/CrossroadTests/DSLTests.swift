import Foundation
import XCTest
import Crossroad

func presentPokemonViewController(pokedexID: Int) {
}

final class DSLTests: XCTestCase {
    func testDSL() throws {
        let customURLScheme: LinkSource = .urlScheme("pokedex")
        let universalLink: LinkSource = .universalLink(URL(string: "https://my-awesome-pokedex.com")!)
        typealias Route = SimpleRouter.Route
        let router = try SimpleRouter(accepts: [customURLScheme, universalLink]) {
            Route("/pokemons/:id") { context in
                guard let pokedexID: Int = context.arguments.id else { return false }
                presentPokemonViewController(pokedexID: pokedexID)
                return true
            }

            Route("/pokemons/search", accepts: .onlyFor(customURLScheme)) { _ in
                true
            }
        }
        XCTAssertTrue(router.responds(to: URL(string: "pokedex://pokemons/42")!))
    }
}
