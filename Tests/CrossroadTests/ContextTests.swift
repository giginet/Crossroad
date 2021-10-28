import Foundation
import XCTest
@testable import Crossroad

final class ContextTests: XCTestCase {
    let url = URL(string: "pokedex://searches")!

    enum Region: String, Parsable {
        case kanto
        case johto
        case hoenn
    }

    var context: Context<Void> {
        return  Context<Void>(url: url,
                              arguments: Arguments(["pokedexID": "25", "name": "Pikachu"]),
                              queryParameters: QueryParameters([
                                URLQueryItem(name: "name", value: "Pikachu"),
                                URLQueryItem(name: "type", value: "electric"),
                                URLQueryItem(name: "region", value: "kanto"),
                                URLQueryItem(name: "name2", value: "Mewtwo"),
                                ]),
                              userInfo: ())
    }

    func regexp(_ string: String) -> NSRegularExpression {
        return try! NSRegularExpression(pattern: string, options: [])
    }

    func testArguments() throws {
        XCTAssertEqual(try context.argument(for: "pokedexID"), 25)
        XCTAssertEqual(try context.argument(for: "pokedexID", as: Int.self), 25)
        XCTAssertEqual(try context.argument(for: "name"), "Pikachu")
        XCTAssertThrowsError(try context.argument(for: "name", as: Int.self)) { error in
            switch error as? Arguments.Error {
            case .couldNotParse(let invalidType):
                XCTAssertNotNil(invalidType)
            case .keyNotFound, .none:
                XCTFail("This error should not be raised.")
            }
        }
        XCTAssertThrowsError(try context.argument(for: "unknown_key", as: Int.self)) { error in
            switch error as? Arguments.Error {
            case .keyNotFound(let unknownKey):
                XCTAssertEqual(unknownKey, "unknown_key")
            case .couldNotParse, .none:
                XCTFail("This error should not be raised.")
            }
        }
    }

    func testParameters() {
        XCTAssertEqual(context.queryParameter(for: "name"), "Pikachu")
        XCTAssertNil(context.queryParameter(for: "foo") as String?)
        XCTAssertNil(context.queryParameter(for: "foo", as: String.self))
        XCTAssertEqual(context.queryParameter(for: "region"), Region.kanto)
        XCTAssertEqual(context.queryParameter(for: "NaMe"), "Pikachu")
        XCTAssertEqual(context.queryParameter(for: "NAME2"), "Mewtwo")
    }

    func testParametersByRegexp() {
        XCTAssertEqual(context.parameter(matchesIn: regexp("name")), "Pikachu")
        XCTAssertEqual(context.parameter(matchesIn: regexp("2$")), "Mewtwo")
        XCTAssertEqual(context.parameter(matchesIn: regexp("^t")), "electric")
        XCTAssertEqual(context.parameter(matchesIn: regexp(".*")), "Pikachu")
        XCTAssertEqual(context.parameter(matchesIn: regexp("region")), Region.kanto)
        XCTAssertNil(context.parameter(matchesIn: regexp("foo")) as String?)
    }

    func testSubscriptParameter() {
        XCTAssertEqual(context[queryParameter: "name"], "Pikachu")
        XCTAssertEqual(context[queryParameter: "type"], "electric")
        XCTAssertEqual(context[queryParameter: "region"], Region.kanto)
        XCTAssertNil(context[queryParameter: "moves"] as [String]?)
    }

    func testDynamicMemberLookup() {
        XCTAssertNil(context.queryParameters.pokedexID as Int?)
        XCTAssertEqual(context.queryParameters.region, "kanto")
    }
}
