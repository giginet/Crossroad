import Foundation
import XCTest
import Crossroad

enum PokemonType: String, Parsable {
    case normal
    case grass
    case water
}

func presentPokemonViewController(pokedexID: Int) {
}

func presentPokemonSearchViewController(name: String?, types: [PokemonType]?) {
}

final class DSLTests: XCTestCase {
    func testDSL() throws {
        let customURLScheme: LinkSource = .customURLScheme("pokedex")
        let universalLink: LinkSource = .universalLink(URL(string: "https://my-awesome-pokedex.com")!)

        let router = try SimpleRouter(accepts: [customURLScheme, universalLink]) { route in
            route("/pokemons/:id") { context in
                let pokedexID: Int = try context.argument(for: "id")
                presentPokemonViewController(pokedexID: pokedexID)
                return true
            }

            route("/pokemons/search", accepts: .onlyFor(customURLScheme)) { context in
                let name: String? = context.parameters.name
                let types: [PokemonType]? = context.parameters.types
                presentPokemonSearchViewController(name: name, types: types)
                return true
            }
        }
        XCTAssertTrue(router.responds(to: URL(string: "pokedex://pokemons/42")!))
    }
}
