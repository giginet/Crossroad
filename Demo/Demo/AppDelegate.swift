import UIKit
import SwiftUI
import Crossroad

struct ApplicationKey: EnvironmentKey {
    static let defaultValue: UIApplication? = nil
}

extension EnvironmentValues {
    var application: UIApplication? {
        get {
            self[ApplicationKey.self]
        }
        set {
            self[ApplicationKey.self] = newValue
        }
    }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private func present<V: View>(view: V) {
        self.window?.rootViewController?.present(UIHostingController(rootView: view),
                                                 animated: true,
                                                 completion: nil)
    }

    private lazy var router: DefaultRouter! = {
        try! DefaultRouter(accepting: [.customURLScheme("pokedex")]) { registry in
            registry.route("/pokemons/:id") { context in
                let pokedexID: Int = try context.argument(named: "id")

                guard let pokemon = Pokedex().pokemon(for: pokedexID) else {
                    throw Pokedex.Error.pokemonNotFound(pokedexID)
                }
                let pokemonDetailView = PokemonDetailView(pokemon: pokemon)
                self.present(view: pokemonDetailView)
            }

            registry.route("/pokemons/search") { context in
                let types: [Pokemon.PokemonType]? = context.queryParameters.types
                let region: Pokemon.Region? = context.queryParameters.region

                let query = PokemonSearchView.Query(types: types.map(Set.init), region: region)

                let pokemonSearchView = PokemonSearchView(query: query)
                self.present(view: pokemonSearchView)
            }
        }
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window

        let topView = TopView().environment(\.application, application)

        window.rootViewController = UIHostingController(rootView: topView)
        window.makeKeyAndVisible()

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return router.openIfPossible(url, options: options)
    }
}
