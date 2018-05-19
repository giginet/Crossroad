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
}
