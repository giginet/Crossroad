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
    
    func testWithRawValues() {
        XCTAssertEqual(Int.extract(from: "25"), 25)
        XCTAssertEqual(Int64.extract(from: "25"), 25)
        XCTAssertEqual(Float.extract(from: "25.5"), 25.5)
        XCTAssertEqual(Double.extract(from: "25.5"), 25.5)
        XCTAssertEqual(Bool.extract(from: "true"), true)
        XCTAssertEqual(String.extract(from: "25"), "25")
        XCTAssertEqual(URL.extract(from: "https://example.com"), URL(string: "https://example.com")!)
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
