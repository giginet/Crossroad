import Foundation
import XCTest
@testable import Crossroad

final class ContextTests: XCTestCase {
    let url = URL(string: "pokedex://searches")!

    enum Region: String, Extractable {
        case kanto
        case johto
        case hoenn
    }

    var context: Context<Void> {
        return  Context<Void>(url: url,
                              arguments: [:],
                              parameters: [
                                URLQueryItem(name: "name", value: "Pikachu"),
                                URLQueryItem(name: "type", value: "electric"),
                                URLQueryItem(name: "region", value: "kanto"),
                                URLQueryItem(name: "name2", value: "Mewtwo"),
                                ],
                              userInfo: ())
    }

    func regexp(_ string: String) -> NSRegularExpression {
        return try! NSRegularExpression(pattern: string, options: [])
    }

    func testParameter() {
        XCTAssertEqual(context.parameter(for: "name"), "Pikachu")
        XCTAssertNil(context.parameter(for: "foo") as String?)
        XCTAssertEqual(context.parameter(for: "region"), Region.kanto)
        XCTAssertNil(context.parameter(for: "NaMe") as String?)
        XCTAssertEqual(context.parameter(for: "NaMe", caseInsensitive: true), "Pikachu")
        XCTAssertEqual(context.parameter(for: "NAME2", caseInsensitive: true), "Mewtwo")
    }

    func testParametersByRegexp() {
        XCTAssertEqual(context.parameter(matchesIn: regexp("name")), "Pikachu")
        XCTAssertEqual(context.parameter(matchesIn: regexp("2$")), "Mewtwo")
        XCTAssertEqual(context.parameter(matchesIn: regexp("^t")), "electric")
        XCTAssertEqual(context.parameter(matchesIn: regexp(".*")), "Pikachu")
        XCTAssertEqual(context.parameter(matchesIn: regexp("region")), Region.kanto)
        XCTAssertNil(context.parameter(matchesIn: regexp("foo")) as String?)
    }
}
