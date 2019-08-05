import Foundation
import Crossroad
import XCTest

final class URLParserTests: XCTestCase {
    func testURLParser() {
        let parser = URLParser<Void>()
        let context = parser.parse(URL(string: "pokedex://pokemons/25")!, in: "pokedex://pokemons/:pokedexID")
        XCTAssertEqual(try context?.argument(for: "pokedexID"), 25)
    }
}
