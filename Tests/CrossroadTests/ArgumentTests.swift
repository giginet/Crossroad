import Foundation
import XCTest
@testable import Crossroad

final class ArgumentTests: XCTestCase {
    func testWithEnum() {
        enum PokemonType: String, Argument {
            case fire
            case grass
            case water
        }
        XCTAssertEqual(PokemonType(string: "fire"), PokemonType.fire)
        XCTAssertNil(PokemonType(string: "fairly"))
    }

    func testWithCommaSeparatedList() {
        XCTAssertEqual([Int].init(string: "1,2,3,4,5"), [1, 2, 3, 4, 5])
        XCTAssertEqual([String].init(string: "a,,c,d,,,,f"), ["a", "c", "d", "f"])
    }
}
