import Foundation
import XCTest
@testable import Crossroad

class RegularExpression: NSRegularExpression, Parsable {
    required public init?(from string: String) {
        try! super.init(pattern: string, options: .caseInsensitive)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ParsableTests: XCTestCase {
    enum PokemonType: String, Parsable {
        case fire
        case grass
        case water
    }

    func testWithEnum() {
        XCTAssertEqual(PokemonType(from: "fire"), .fire)
        XCTAssertNil(PokemonType(from: "faily"))
    }

    func testWithCommaSeparatedList() {
        XCTAssertEqual([Int](from: "1,2,3,4,5"), [1, 2, 3, 4, 5])
        XCTAssertEqual([String](from: "a,,c,d,,,,f"), ["a", "c", "d", "f"])
        XCTAssertEqual([Double](from: "1.1"), [1.1])
        XCTAssertEqual([PokemonType](from: "water,grass"), [.water, .grass])
    }

    func testWithCustomClass() {
        XCTAssertNotNil(RegularExpression(from: ".+"))
    }
}
