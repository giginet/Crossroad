import Foundation
import XCTest
import Crossroad

final class Router_AcceptanceTests: XCTestCase {
    private let customURLScheme: LinkSource = .customURLScheme("pokedex")
    private let universalLink: LinkSource = .universalLink(URL(string: "https://my-awesome-pokedex.com")!)
    private let anotherUniversalLink: LinkSource = .universalLink(URL(string: "https://another-pokedex.com")!)

    func testAcceptOnly() throws {
        let router = try SimpleRouter(accepting: [customURLScheme, universalLink]) { registry in
            registry.route("/pokemons/:id", accepting: .only(for: universalLink)) { _ in }
        }

        XCTAssertFalse(router.responds(to: URL(string: "pokedex://pokemons/:id")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://my-awesome-pokedex.com/pokemons/:id")!))
    }

    func testAcceptOnlyWithGroup() throws {
        let router = try SimpleRouter(accepting: [customURLScheme, universalLink]) { registry in
            registry.group(accepting: [universalLink]) { group in
                group.route("/pokemons/:id") { _ in }
            }

            registry.group(accepting: [customURLScheme]) { group in
                group.route("/moves/:id") { _ in }
            }
        }

        XCTAssertFalse(router.responds(to: URL(string: "pokedex://pokemons/:id")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://my-awesome-pokedex.com/pokemons/:id")!))
        XCTAssertTrue(router.responds(to: URL(string: "pokedex://moves/:id")!))
        XCTAssertFalse(router.responds(to: URL(string: "https://my-awesome-pokedex.com/moves/:id")!))
    }

    func testAcceptOnlyWithGroupWithAnotherUniversalLink() throws {
        let router = try SimpleRouter(accepting: [customURLScheme, universalLink, anotherUniversalLink]) { registry in
            registry.group(accepting: [universalLink]) { group in
                group.route("/pokemons/:id") { _ in }
            }

            registry.group(accepting: [anotherUniversalLink]) { group in
                group.route("/moves/:id") { _ in }
            }

            registry.route("/") { _ in }
        }

        XCTAssertFalse(router.responds(to: URL(string: "pokedex://pokemons/:id")!))
        XCTAssertFalse(router.responds(to: URL(string: "pokedex://moves/:id")!))
        XCTAssertTrue(router.responds(to: URL(string: "pokedex://")!))

        XCTAssertTrue(router.responds(to: URL(string: "https://my-awesome-pokedex.com/pokemons/:id")!))
        XCTAssertFalse(router.responds(to: URL(string: "https://my-awesome-pokedex.com/moves/:id")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://my-awesome-pokedex.com/")!))

        XCTAssertFalse(router.responds(to: URL(string: "https://another-pokedex.com/pokemons/:id")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://another-pokedex.com/moves/:id")!))
        XCTAssertTrue(router.responds(to: URL(string: "https://another-pokedex.com/")!))
    }

    func testGroupDSLWithWrongFactory() throws {
        // It should be compilation-time error!
//        let router = try SimpleRouter(accepting: [customURLScheme, universalLink]) { registry in
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
