import Foundation
@testable import Crossroad
import XCTest

final class PatternTests: XCTestCase {
    func testParsePattern() throws {
        let testCases: [(UInt, String, LinkSource, Path)] = [
            (   #line,
                "https://pokedex.com/pokemons/:id",
                .universalLink(URL(string: "https://pokedex.com")!),
                Path(components: ["pokemons", ":id"])
            ),
            (   #line,
                "pokedex://pokemons/:id",
                .urlScheme("pokedex"),
                Path(components: ["pokemons", ":id"])
            ),
            (   #line,
                "foobar://static",
                .urlScheme("foobar"),
                Path(components: ["static"])
            ),
        ]

        for (line, patternString, expectedLinkSource, expectedPath) in testCases {
            let pattern = try Pattern(patternString: patternString)
            XCTAssertEqual(pattern.linkSource, expectedLinkSource, line: line)
            XCTAssertEqual(pattern.path, expectedPath, line: line)
        }
    }
}
