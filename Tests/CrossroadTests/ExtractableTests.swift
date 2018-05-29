import Foundation
import XCTest
@testable import Crossroad

extension NSRegularExpression: Extractable {
    public static func extract(from string: String) -> Self? {
        return try? .init(pattern: string, options: .caseInsensitive)
    }
}

final class ExtractableTests: XCTestCase {
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

    func testWithCustomClass() {
        XCTAssertNotNil(NSRegularExpression.extract(from: ".+"))
    }
}
