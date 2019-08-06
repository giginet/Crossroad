import Foundation
import Crossroad
import XCTest

final class URLParserTests: XCTestCase {
    func testURLParser() {
        let parser = URLParser<Void>()
        let context = parser.parse(URL(string: "pokedex://pokemons/25")!, in: "pokedex://pokemons/:pokedexID")
        XCTAssertEqual(try context?.argument(for: "pokedexID"), 25)
    }

    func testPatternCase() {
        let parser = URLParser<Void>()

        let testCases: [(String, String, Bool, UInt)] = [
            ("http://my-awesome-pokedex.com/pokemons", "HTTP://MY-AWESOME-POKEDEX.COM/pokemons", true, #line),
            ("http://my-awesome-pokedex.com/pokemons", "HTTP://MY-AWESOME-POKEDEX.COM/POKEMONS", false, #line),
        ]

        for (pattern, urlString, result, line) in testCases {
            let url = URL(string: urlString)!
            let context = parser.parse(url, in: pattern)
            if result {
                XCTAssertNotNil(context, line: line)
            } else {
                XCTAssertNil(context, line: line)
            }
        }
    }
}
