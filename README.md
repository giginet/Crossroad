[![Crossroad](Documentation/logo.png)](https://github.com/giginet/Crossroad)

[![Build Status](https://img.shields.io/github/workflow/status/giginet/Crossroad/Crossroad?style=flat-square)](https://github.com/giginet/Crossroad/actions?query=workflow%3ACrossroad)
[![Language](https://img.shields.io/static/v1.svg?label=language&message=Swift%205.4&color=FA7343&logo=swift&style=flat-square)](https://swift.org)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-4BC51D.svg?style=flat-square)](https://swift.org/package-manager/) 
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage) 
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Crossroad.svg?style=flat-square)](http://cocoapods.org/pods/Crossroad)
[![Platform](https://img.shields.io/static/v1.svg?label=platform&message=iOS|tvOS&color=grey&logo=apple&style=flat-square)](http://cocoapods.org/pods/Crossroad)
[![License](https://img.shields.io/cocoapods/l/Crossroad.svg?style=flat-square)](https://github.com/giginet/Crossroad/blob/master/LICENSE)

Route URL schemes easily.

Crossroad is an URL router focused on handling Custom URL Schemes or Universal Links.
Of cource, you can also use for [Firebase Dynamic Link](https://firebase.google.com/docs/dynamic-links) or other similar services.

Using this, you can route multiple URL schemes and fetch arguments and parameters easily.

This library is developed in working time for Cookpad.

## Basic Usage

You can use `DefaultRouter` to define route definitions.

Imagine to implement Pokédex on iOS. You can access somewhere via URL scheme.

```swift
import Crossroad

let customURLScheme: LinkSource = .customURLScheme("pokedex")
let universalLink: LinkSource = .universalLink(URL(string: "https://my-awesome-pokedex.com")!)

do {
    let router = try DefaultRouter(accepting: [customURLScheme, universalLink]) { registry in
        registry.route("/pokemons/:pokedexID") { context in 
            let pokedexID: Int = try context.argument(named: "pokedexID") // Parse 'pokedexID' from URL
            if !Pokedex.isExist(pokedexID) { // Find the Pokémon by ID
                throw PokedexError.pokemonIsNotExist(pokedexID) // If Pokémon is not found. Try next route definition.
            }
            presentPokedexDetailViewController(of: pokedexID)
        }
        registry.route("/pokemons") { context in 
            let type: Type? = context.queryParameters.type // If URL contains &type=fire, you can get Fire type.
            presentPokedexListViewController(for: type)
        }

        // ...
    }
} catch {
    // If route definitions have some problems, routers fail initialization and raise reasons.
    fatalError(error.localizedDescription)
}

// Pikachu(No. 25) is exist! so you can open Pikachu's page.
let canRespond25 = router.responds(to: URL(string: "pokedex://pokemons/25")!) // true
// No. 9999 is missing. so you can't open this page.
let canRespond9999 = router.responds(to: URL(string: "pokedex://pokemons/9999")!) // false
// You can also open the pages via universal links.
let canRespondUniversalLink = router.responds(to: URL(string: "https://my-awesome-pokedex.com/pokemons/25")!) // true

// Open Pikachu page
router.openIfPossible(URL(string: "pokedex://pokemons/25")!)
// Open list of fire Pokémons page
router.openIfPossible(URL(string: "pokedex://pokemons?type=fire")!)
```

### Using AppDelegate

In common use case, you should call `router.openIfPossible` on `UIApplicationDelegate` method.

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
    if router.responds(to: url, options: options) {
        return router.openIfPossible(url, options: options)
    }
    return false
}
```

### Using SceneDelegate

Or, if you are using `SceneDelegate` with a modern app:

```swift
func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let context = URLContexts.first else {
        return
    }
    router.openIfPossible(context.url, options: context.options)
}
```

### Using NSApplicationDelegate (for macOS)

If you develop macOS applications:

```swift
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let appleEventManager = NSAppleEventManager.shared()
        appleEventManager.setEventHandler(self,
                                          andSelector: #selector(handleURLEvent(event:replyEvent:)),
                                          forEventClass: AEEventClass(kInternetEventClass),
                                          andEventID: AEEventID(kAEGetURL))
    }

    @objc func handleURLEvent(event: NSAppleEventDescriptor?, replyEvent: NSAppleEventDescriptor?) {
        guard let urlString = event?.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue else { return }
        guard let url = URL(string: urlString) else { return }
        router.openIfPossible(context.url, options: [:])
    }
}
```

## Argument and Parameter

### Argument

`:` prefixed components on passed URL pattern mean **argument**.

For example, if passed URL matches `pokedex://search/:keyword`, you can get `keyword` from `Context`.

```swift
// actual URL: pokedex://search/Pikachu
let keyword: String = try context.arguments(named: "keyword") // Pikachu
```

### QueryParameter

And more, you can get query parameters if exist.

```swift
// actual URL: pokedex://search/Pikachu?generation=1
let generation: Int? = context.queryParameters["generation"] // 1
// or you can also get value using DynamicMemberLookup
let generation: Int? = context.queryParameters.generation // 1
```

You can cast arguments/query parameters as any type. Crossroad attempt to cast each String values to the type.

```swift
// expected pattern: pokedex://search/:pokedexID
// actual URL: pokedex://search/25
let pokedexID: Int = try context.arguments(named: "keyword") // 25
```

Currently supported types are `Int`, `Int64`, `Float`, `Double`, `Bool`, `String` and `URL`.

### Enum arguments

You can use enums as arguments by conforming to `Parsable`.

```swift
enum Type: String, Parsable {
    case normal
    case fire
    case water
    case grass
    // ....
}

// matches: pokedex://pokemons?type=fire
let type: Type? = context.queryParameters.type // .fire
```

### Comma-separated list

You can treat comma-separated query strings as `Array` or `Set`.

```swift
// matches: pokedex://pokemons?types=water,grass
let types: [Type]? = context.queryParameters.types // [.water, .grass]
```

### Custom argument

You can also define own arguments by implementing `Parsable`.
This is an example to parse custom struct.

```swift
struct User {
    let name: String
}
extension User: Parsable {
    init?(from string: String) {
        self.name = string
    }
}
```

## Multiple link sources support

You can define complex routing definitions like following:

```swift
let customURLScheme: LinkSource = .customURLScheme("pokedex")
let pokedexWeb: LinkSource = .universalLink(URL(string: "https://my-awesome-pokedex.com")!)
let anotherWeb: LinkSource = .universalLink(URL(string: "https://kanto.my-awesome-pokedex.com")!)

let router = try DefaultRouter(accepting: [customURLScheme, pokedexWeb, anotherWeb]) { registry in
    // Pokémon detail pages can be opened from all sources.
    registry.route("/pokemons/:pokedexID") { context in 
        let pokedexID: Int = try context.argument(named: "pokedexID") // Parse 'pokedexID' from URL
        if !Pokedex.isExist(pokedexID) { // Find the Pokémon by ID
            throw PokedexError.pokemonIsNotExist(pokedexID)
        }
        presentPokedexDetailViewController(of: pokedexID)
    }

    // Move related pages can be opened only from Custom URL Schemes
    registry.group(accepting: [customURLScheme]) { group in
        group.route("/moves/:move_name") { context in 
            let moveName: String = try context.argument(named: "move_name")
            presentMoveViewController(for: moveName)
        }
        group.route("/pokemons/:pokedexID/move") { context in 
            let pokedexID: Int = try context.argument(named: "pokedexID")
            presentPokemonMoveViewController(for: pokedexID)
        }
    }

    // You can pass acceptPolicy for a specific page.
    registry.route("/regions", accepting: .only(for: pokedexWeb)) { context in 
        presentRegionListViewController()
    }
}
```

This router can treat three link sources.

## Custom Router

You can add any payload to `Router`.

```swift
struct UserInfo {
    let userID: Int64
}
let router = try Router<UserInfo>(accepting: customURLScheme) { registry in
    registry.route("pokedex://pokemons") { context in 
        let userInfo: UserInfo = context.userInfo
        let userID = userInfo.userID
    }
    // ...
])
let userInfo = UserInfo(userID: User.current.id)
router.openIfPossible(url, userInfo: userInfo)
```

## Parse URL patterns

If you maintain a complex application and you want to use independent URL pattern parsers without Router.
You can use `ContextParser`.

```swift
let parser = ContextParser()
let context = parser.parse(URL(string: "pokedex:/pokemons/25")!, 
                           with: "pokedex://pokemons/:id")
```

## Installation

### Swift Package Manager

- File > Swift Packages > Add Package Dependency
- Add https://github.com/giginet/Crossroad.git
    Select "Up to Next Major" with "4.0.0"

### CocoaPods

```ruby
use_frameworks!

pod 'Crossroad'
```

### Carthage

```
github "giginet/Crossroad"
```

## Demo

1. Open `Demo/Demo.xcodeproj` on Xcode.
2. Build `Demo` schema.

## Supported version

Latest version of Crossroad requires Swift 5.2 or above.

Use 1.x instead on Swift 4.1 or lower.

|Crossroad Version|Swift Version|Xcode Version|
|-----------------|-------------|-------------|
|4.x              |5.4          |Xcode 13.0   |
|3.x              |5.0          |Xcode 10.3   |
|2.x              |5.0          |Xcode 10.2   |
|1.x              |4.0 ~ 4.2    |~ Xcode 10.1 |

## License

Crossroad is released under the MIT License.

Header logo is released under the [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) license. Original design by [@Arslanshn](https://github.com/Arslanshn).
