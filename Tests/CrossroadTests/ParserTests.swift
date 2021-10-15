import XCTest
import Crossroad

final class ParserTests: XCTestCase {
    func testURLParser() {
        let parser = Parser()
        let pattern = Pattern(linkSource: .urlScheme("pokedex"),
                              path: "/pokemons/:pokedexID")
        let context = parser.parse(URL(string: "pokedex://pokemons/25")!, in: pattern)
        XCTAssertEqual(try context?.argument(for: "pokedexID"), 25)
    }

    func testPatternCase() throws {
        let parser = Parser()

        let testCases: [(String, String, Bool, UInt)] = [
//            ("http://my-awesome-pokedex.com/pokemons", "HTTP://MY-AWESOME-POKEDEX.COM/pokemons", true, #line),
            ("http://my-awesome-pokedex.com/pokemons", "HTTP://MY-AWESOME-POKEDEX.COM/POKEMONS", false, #line),
//            ("pokedex://pokemons/fire", "pokedex://pokemons/FIRE", false, #line),
//            ("pokedex://pokemons/fire", "POKEDEX://POKEMONS/fire", true, #line),
//            ("pokedex://pokemons/fire", "POKEDEX://POKEMONS/FIRE", false, #line),
        ]

        for (patternString, urlString, result, line) in testCases {
            let url = URL(string: urlString)!
            let pattern = try Pattern(patternString: patternString)
            let context = parser.parse(url, in: pattern)
            if result {
                XCTAssertNotNil(context, line: line)
            } else {
                XCTAssertNil(context, line: line)
            }
        }
    }
}
