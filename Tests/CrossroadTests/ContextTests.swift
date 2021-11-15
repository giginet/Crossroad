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
        XCTAssertEqual(try context.argument(named: "pokedexID"), 25)
        XCTAssertEqual(try context.argument(named: "pokedexID", as: Int.self), 25)
        XCTAssertEqual(try context.argument(named: "name"), "Pikachu")
        XCTAssertThrowsError(try context.argument(named: "name", as: Int.self)) { error in
            switch error as? Arguments.Error {
            case .couldNotParse(let invalidType):
                XCTAssertNotNil(invalidType)
            case .keyNotFound, .none:
                XCTFail("This error should not be raised.")
            }
        }
        XCTAssertThrowsError(try context.argument(named: "unknown_key", as: Int.self)) { error in
            switch error as? Arguments.Error {
            case .keyNotFound(let unknownKey):
                XCTAssertEqual(unknownKey, "unknown_key")
            case .couldNotParse, .none:
                XCTFail("This error should not be raised.")
            }
        }
    }

    func testParameters() {
        XCTAssertEqual(context.queryParameter(named: "name"), "Pikachu")
        XCTAssertNil(context.queryParameter(named: "foo") as String?)
        XCTAssertEqual(context.queryParameter(named: "region"), Region.kanto)
        XCTAssertEqual(context.queryParameter(named: "NaMe"), "Pikachu")
        XCTAssertEqual(context.queryParameter(named: "NAME2"), "Mewtwo")
    }

    func testRequiredQueryParameters() throws {
        XCTAssertNoThrow(try context.requiredQueryParameter(named: "name", as: String.self))
        XCTAssertThrowsError(try context.requiredQueryParameter(named: "foo", as: String.self)) { error in
            guard case QueryParameters.Error.missingRequiredQueryParameter(let key) = error else {
                return XCTFail("unknown error type")
            }
            XCTAssertEqual(key, "foo")
        }
        XCTAssertNoThrow(try context.requiredQueryParameter(named: "region", as: Region.self))
        XCTAssertThrowsError(try context.requiredQueryParameter(named: "name", as: Int.self), "'name' should not be Integer") { error in
            guard case QueryParameters.Error.missingRequiredQueryParameter(let key) = error else {
                return XCTFail("unknown error type")
            }
            XCTAssertEqual(key, "name")
        }
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
        XCTAssertEqual(context.queryParameters["name"], "Pikachu")
        XCTAssertEqual(context.queryParameters["type"], "electric")
        XCTAssertEqual(context.queryParameters["region"], Region.kanto)
        XCTAssertNil(context.queryParameters["moves"] as [String]?)
    }

    func testDynamicMemberLookup() {
        XCTAssertNil(context.queryParameters.pokedexID as Int?)
        XCTAssertEqual(context.queryParameters.region, "kanto")
    }
}
