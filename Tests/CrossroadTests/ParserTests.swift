import XCTest
@testable import Crossroad

final class ParserTests: XCTestCase {
    func testURLParser() throws {
        let parser = ContextParser<Void>()
        let patternString = "pokedex://pokemons/:pokedexID"
        let context = try parser.parse(URL(string: "pokedex://pokemons/25")!, with: patternString)
        XCTAssertEqual(try context.argument(named: "pokedexID"), 25)
    }

    func testPatternCase() throws {
        let parser = ContextParser<Void>()

        let testCases: [(String, String, Bool, UInt)] = [
            ("http://my-awesome-pokedex.com/pokemons", "HTTP://MY-AWESOME-POKEDEX.COM/pokemons", true, #line),
            ("http://my-awesome-pokedex.com/pokemons", "HTTP://MY-AWESOME-POKEDEX.COM/POKEMONS", false, #line),
            ("pokedex://pokemons/fire", "pokedex://pokemons/FIRE", false, #line),
            ("pokedex://pokemons/fire", "POKEDEX://POKEMONS/fire", true, #line),
            ("pokedex://pokemons/fire", "POKEDEX://POKEMONS/FIRE", false, #line),
            ("pokedex://", "pokedex://", true, #line),
            ("http://my-awesome-pokedex.com", "http://my-awesome-pokedex.com", true, #line),
            ("http://my-awesome-pokedex.com/pokemons/:id", "http://totally-different-url.com/pokemons/100", false, #line),
        ]

        for (patternString, urlString, result, line) in testCases {
            let url = URL(string: urlString)!
            let context = try? parser.parse(url, with: patternString)
            if result {
                XCTAssertNotNil(context, line: line)
            } else {
                XCTAssertNil(context, line: line)
            }
        }
    }
}
