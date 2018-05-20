import Foundation
import XCTest
@testable import Crossroad

final class ArgumentTests: XCTestCase {
    enum PokemonType: String, Argument {
        case fire
        case grass
        case water
    }
    
    func testWithEnum() {
        XCTAssertEqual(PokemonType(string: "fire"), .fire)
        XCTAssertNil(PokemonType(string: "faily"))
    }

    func testWithCommaSeparatedList() {
        XCTAssertEqual([Int].init(string: "1,2,3,4,5"), [1, 2, 3, 4, 5])
        XCTAssertEqual([String].init(string: "a,,c,d,,,,f"), ["a", "c", "d", "f"])
        XCTAssertEqual([Double].init(string: "1.1"), [1.1])
        XCTAssertEqual([PokemonType].init(string: "water,grass"), [.water, .grass])
    }
}
