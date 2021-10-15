import Foundation
import XCTest
import Crossroad

let pokedex: LinkSource = .urlScheme("pokedex")
let pokedexWeb: LinkSource = .universalLink(URL(string: "https://my-awesome-pokedex.com")!)

final class DSLTests: XCTestCase {
    func testDSL() {
        let router = SimpleRouter([]) {
            R("/pokemons/:id") { context in
                let pokedexID: Int? = context.id
                return true
            }

            R("/pokemons/search", accepts: .onlyFor([pokedex])) { context in
                let pokedexID: Int? = context.id
                return true
            }
        }
        router.responds(to: URL(string: "pokedex://pokemon/42")!)

//        enum MyProvider: Provider {
//            static let urlScheme = URLScheme("pokedex")
//            static let universalLink = UniversalLink(URL("https://my-awesome-pokedex.com")!)
//        }

//        let router = Router(provider) {
//            Route("/pokemons/:id") { context in
//                let pokedexID = context.id
//                presentPokemonViewController(for: pokedexID)
//            }
//
//            AcceptOnly(for: [.urlScheme]) {
//                Route("/pokemons/:id") { context in
//                    let pokedexID = context.id
//                    presentPokemonViewController(for: pokedexID)
//                }
//                Route("", executor)
//            }
//        }
    }
}
