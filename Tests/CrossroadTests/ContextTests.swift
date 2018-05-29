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
        XCTAssertEqual(context.parameters.name, "Pikachu")
        XCTAssertNil(context.parameters.foo as String?)
        XCTAssertEqual(context.parameters.region, Region.kanto)
        XCTAssertNil(context.parameters.fetch(for: "NaMe") as String?)
        XCTAssertEqual(context.parameters.fetch(for: "NaMe", caseInsensitive: true), "Pikachu")
        XCTAssertEqual(context.parameters.fetch(for: "NAME2", caseInsensitive: true), "Mewtwo")
    }

    func testParametersByRegexp() {
        XCTAssertEqual(context.parameters.fetch(matchesIn: regexp("name")), "Pikachu")
        XCTAssertEqual(context.parameters.fetch(matchesIn: regexp("2$")), "Mewtwo")
        XCTAssertEqual(context.parameters.fetch(matchesIn: regexp("^t")), "electric")
        XCTAssertEqual(context.parameters.fetch(matchesIn: regexp(".*")), "Pikachu")
        XCTAssertEqual(context.parameters.fetch(matchesIn: regexp("region")), Region.kanto)
        XCTAssertNil(context.parameters.fetch(matchesIn: regexp("foo")) as String?)
    }
}
