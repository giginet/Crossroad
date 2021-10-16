import Foundation
@testable import Crossroad
import XCTest

enum TestResult<Success, Failure> {
    case success(Success)
    case failure(Failure)
}

final class PatternTests: XCTestCase {
    func testParsePattern() throws {
        let testCases: [(UInt, String, TestResult<(LinkSource?, Path), Pattern.ParsingError>)] = [
            (   #line,
                "https://pokedex.com/pokemons/:id",
                .success((.universalLink(URL(string: "https://pokedex.com")!),
                          Path(components: ["pokemons", ":id"])))
            ),
            (   #line,
                "pokedex://pokemons/:id",
                .success((.urlScheme("pokedex"),
                          Path(components: ["pokemons", ":id"])))
            ),
            (   #line,
                "/pokemons/:id",
                .success((nil,
                          Path(components: ["pokemons", ":id"])))
            ),
            (   #line,
                "pokemons/:id",
                .success((nil,
                          Path(components: ["pokemons", ":id"])))
            ),
            (   #line,
                "pokedex://:id",
                .success((.urlScheme("pokedex"),
                          Path(components: [":id"])))
            ),
            (   #line,
                "http://localhost:3000/:id",
                .success((.universalLink(URL(string: "http://localhost:3000")!),
                          Path(components: [":id"])))
            ),
            (   #line,
                "aaaaaaaaaaa",
                .success((nil,
                          Path(components: ["aaaaaaaaaaa"])))
            ),
            (   #line,
                "aaaaaa//////////aaaaa",
                .success((nil,
                          Path(components: ["aaaaaa", "aaaaa"])))
            ),
            (   #line,
                "///////////////",
                .failure(.invalidURL)
            ),
            (   #line,
                "http://",
                .failure(.invalidURL)
            ),
            (   #line,
                "pokedex://",
                .failure(.invalidURL)
            ),
        ]

        for (line, patternString, result) in testCases {
            switch result {
            case .success(let success):
                let pattern = try Pattern(patternString: patternString)
                XCTAssertEqual(pattern.linkSource, success.0, line: line)
                XCTAssertEqual(pattern.path, success.1, line: line)
            case .failure(let failure):
                XCTAssertThrowsError(try Pattern(patternString: patternString)) { error in
                    XCTAssertEqual(error as? Pattern.ParsingError, failure)
                }
            }
        }
    }
}
