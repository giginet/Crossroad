import Foundation
import XCTest
import Crossroad

final class Router_AcceptanceTests: XCTestCase {
    private let customURLScheme: LinkSource = .customURLScheme("pokedex")
    private let universalLink: LinkSource = .universalLink(URL(string: "https://my-awesome-pokedex.com")!)

    func testAcceptOnly() throws {
        let router = try SimpleRouter(accepting: [customURLScheme, universalLink]) { route in
            route("/pokemons/:id", accepting: .only(for: universalLink)) { _ in }
        }

        XCTAssertFalse(router.responds(to: URL(string: "pokedex://pokemons/:id")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://my-awesome-pokedex.com/pokemons/:id")!))
    }

    func testAcceptOnlyWithGroup() throws {
        let router = try SimpleRouter(accepting: [customURLScheme, universalLink]) { route in
            route.group(accepting: [universalLink]) { groupedRoute in
                groupedRoute("/pokemons/:id") { _ in }
            }

            route.group(accepting: [customURLScheme]) { groupedRoute in
                groupedRoute("/moves/:id") { _ in }
            }
        }

        XCTAssertFalse(router.responds(to: URL(string: "pokedex://pokemons/:id")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://my-awesome-pokedex.com/pokemons/:id")!))
        XCTAssertTrue(router.responds(to: URL(string: "pokedex://moves/:id")!))
        XCTAssertFalse(router.responds(to: URL(string: "https://my-awesome-pokedex.com/moves/:id")!))
    }

    func testGroupDSLWithWrongFactory() throws {
        // It should be compilation-time error!
//        let router = try SimpleRouter(accepting: [customURLScheme, universalLink]) { route in
//            route.group(accepting: [universalLink]) { route2 in
//                route("/pokemons/:id") { _ in
//                    true
//                }
//            }
//
//            route.group(accepting: [customURLScheme]) { route2 in
//                route("/moves/:id") { _ in
//                    true
//                }
//            }
//        }
    }
}
