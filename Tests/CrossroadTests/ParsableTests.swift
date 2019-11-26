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

    func testWithPrimitives() {
        XCTAssertEqual(Int(from: "10"), 10)
        XCTAssertEqual(Double(from: "10.0"), 10.0)
        XCTAssertEqual(Int64(from: "10"), 10)
        XCTAssertEqual(Float(from: "10.0"), 10.0)
        XCTAssertFalse(Bool(from: "false")!)
        XCTAssertEqual(String(from: "pokèball"), "pokèball")
        XCTAssertEqual(URL(from: "https://pokedex.com")!, URL(string: "https://pokedex.com"))
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
