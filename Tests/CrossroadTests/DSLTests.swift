import Foundation
import XCTest
import Crossroad

func presentPokemonViewController(pokedexID: Int) {
}

final class DSLTests: XCTestCase {
    func testDSL() throws {
        let customURLScheme: LinkSource = .customURLScheme("pokedex")
        let universalLink: LinkSource = .universalLink(URL(string: "https://my-awesome-pokedex.com")!)

        let router = try SimpleRouter(accepts: [customURLScheme, universalLink]) { route in
            route("/pokemons/:id") { context in
                guard let pokedexID: Int = context.arguments.id else { return false }
                presentPokemonViewController(pokedexID: pokedexID)
                return true
            }

            route("/pokemons/search", accepts: .onlyFor(customURLScheme)) { _ in
                true
            }
        }
        XCTAssertTrue(router.responds(to: URL(string: "pokedex://pokemons/42")!))
    }
}
