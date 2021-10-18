import Foundation
@testable import Crossroad
import XCTest

enum TestResult<Success, Failure> {
    case success(Success)
    case failure(Failure)
}

final class PatternTests: XCTestCase {
    func testParsePattern() throws {
        let testCases: [(UInt, String, TestResult<(LinkSource?, Path), Crossroad.Pattern.ParsingError>)] = [
            (   #line,
                "https://pokedex.com/pokemons/:id",
                .success((.universalLink(URL(string: "https://pokedex.com")!),
                          Path(components: ["pokemons", ":id"])))
            ),
            (   #line,
                "pokedex://pokemons/:id",
                .success((.customURLScheme("pokedex"),
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
                .success((.customURLScheme("pokedex"),
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
                .failure(.invalidPattern("///////////////"))
            ),
            (   #line,
                "http://",
                .failure(.invalidPattern("http://"))
            ),
            (   #line,
                "pokedex://",
                .failure(.invalidPattern("pokedex://"))
            ),
        ]

        for (line, patternString, result) in testCases {
            switch result {
            case .success(let success):
                let pattern = try Pattern(patternString: patternString)
                XCTAssertEqual(pattern.linkSource, success.0, line: line)
                XCTAssertEqual(pattern.path, success.1, line: line)
            case .failure:
                XCTAssertThrowsError(try Pattern(patternString: patternString)) { error in
                    let parsingError = error as? Crossroad.Pattern.ParsingError
                    if case .invalidPattern(let pattern) = parsingError {
                        XCTAssertEqual(pattern, patternString)
                    }
                }
            }
        }
    }
}
