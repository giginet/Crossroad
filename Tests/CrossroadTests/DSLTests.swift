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
    let customURLScheme: LinkSource = .customURLScheme("pokedex")
    let universalLink: LinkSource = .universalLink(URL(string: "https://my-awesome-pokedex.com")!)

    func testDSL() throws {
        let router = try SimpleRouter(accepting: [customURLScheme, universalLink]) { registry in
            registry.route("/pokemons/:id") { context in
                let pokedexID: Int = try context.argument(named: "id")
                presentPokemonViewController(pokedexID: pokedexID)
            }

            registry.route("/pokemons", accepting: .only(for: customURLScheme)) { context in
                let name: String? = context.queryParameters.name
                let types: [PokemonType]? = context.queryParameters.types
                presentPokemonSearchViewController(name: name, types: types)
            }
        }
        XCTAssertTrue(router.responds(to: URL(string: "pokedex://pokemons/42")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://my-awesome-pokedex.com/pokemons/42")!))
        XCTAssertTrue(router.responds(to: URL(string: "pokedex://pokemons")!))
        XCTAssertFalse(router.responds(to: URL(string: "https://my-awesome-pokedex.com/pokemons")!), "Route for '/pokemon' is registerd only for Custom URL Scheme.")
    }

    func testGroupedDSL() throws {
        let router = try SimpleRouter(accepting: [customURLScheme, universalLink]) { registry in
            registry.route("/pokemons/:id") { context in
                let pokedexID: Int = try context.argument(named: "id")
                presentPokemonViewController(pokedexID: pokedexID)
            }

            registry.group(accepting: universalLink) { group in
                group.route("/pokemons") { context in
                    let name: String? = context.queryParameters.name
                    let types: [PokemonType]? = context.queryParameters.types
                    presentPokemonSearchViewController(name: name, types: types)
                }
            }
        }
        XCTAssertTrue(router.responds(to: URL(string: "pokedex://pokemons/42")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://my-awesome-pokedex.com/pokemons/42")!))
        XCTAssertFalse(router.responds(to: URL(string: "pokedex://pokemons")!), "Route for '/pokemons' is registered in accepting group.")
        XCTAssertTrue(router.responds(to: URL(string: "https://my-awesome-pokedex.com/pokemons")!))
    }
}
