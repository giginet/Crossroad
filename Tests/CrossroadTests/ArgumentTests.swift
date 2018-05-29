import Foundation
import XCTest
@testable import Crossroad

final class ArgumentTests: XCTestCase {
    enum PokemonType: String, Extractable {
        case fire
        case grass
        case water
    }

    func testWithEnum() {
        XCTAssertEqual(PokemonType.extract(from: "fire"), .fire)
        XCTAssertNil(PokemonType.extract(from: "faily"))
    }

    func testWithCommaSeparatedList() {
        XCTAssertEqual([Int].extract(from: "1,2,3,4,5"), [1, 2, 3, 4, 5])
        XCTAssertEqual([String].extract(from: "a,,c,d,,,,f"), ["a", "c", "d", "f"])
        XCTAssertEqual([Double].extract(from: "1.1"), [1.1])
        XCTAssertEqual([PokemonType].extract(from: "water,grass"), [.water, .grass])
    }
}
