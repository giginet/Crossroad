import Foundation
import XCTest
@testable import Crossroad

final class ContextTests: XCTestCase {
    let url = URL(string: "pokedex://searches")!
    
    func regexp(_ string: String) -> NSRegularExpression {
        return try! NSRegularExpression(pattern: string, options: [])
    }
    
    func testParametersByRegexp() {
        enum Region: String, Argument {
            case kanto
            case johto
            case hoeen
        }
        let context = Context<Void>(url: url,
                                    arguments: [:],
                                    parameters: [
                                        URLQueryItem(name: "name", value: "Pikachu"),
                                        URLQueryItem(name: "type", value: "electric"),
                                        URLQueryItem(name: "region", value: "kanto"),
                                        URLQueryItem(name: "name2", value: "Mewtwo"),
                                        ],
                                    userInfo: ())
        XCTAssertEqual(context.parameter(matchesIn: regexp("name")), "Pikachu")
        XCTAssertEqual(context.parameter(matchesIn: regexp("2$")), "Mewtwo")
        XCTAssertEqual(context.parameter(matchesIn: regexp("^t")), "electric")
        XCTAssertEqual(context.parameter(matchesIn: regexp(".*")), "Pikachu")
        XCTAssertEqual(context.parameter(matchesIn: regexp("region")), Region.kanto)
        let result: String? = context.parameter(matchesIn: regexp("foo"))
        XCTAssertNil(result)
    }
}
