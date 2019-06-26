[![Crossroad](Documentation/logo.png)](https://github.com/giginet/Crossroad)

[![Build Status](https://img.shields.io/travis/giginet/Crossroad.svg?branch=master&style=flat-square)](https://travis-ci.org/giginet/Crossroad)
[![Language](https://img.shields.io/static/v1.svg?label=language&message=Swift%205&color=FA7343&logo=swift&style=flat-square)](https://swift.org)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage) 
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Crossroad.svg?style=flat-square)](http://cocoapods.org/pods/Crossroad)
[![Platform](https://img.shields.io/static/v1.svg?label=platform&message=iOS&color=grey&logo=apple&style=flat-square)](http://cocoapods.org/pods/Crossroad)
[![License](https://img.shields.io/cocoapods/l/Crossroad.svg?style=flat-square)](https://github.com/giginet/Crossroad/blob/master/LICENSE)

Route URL schemes easily.

Crossroad is an URL router focused on handling Custom URL Scheme.
Using this, you can route multiple URL schemes and fetch arguments and parameters easily.

This library is developed in working time for Cookpad.

## Installation

### CocoaPods

```ruby
use_frameworks!

pod 'Crossroad'
```

### Carthage

```
github "giginet/Crossroad"
```

## Basic Usage

You can use `DefaultRouter` to define route definitions.

Imagine to implement Pokédex on iOS. You can access somewhere via URL scheme.

```swift
router = DefaultRouter(scheme: "pokedex")
router.register([
    ("pokedex://pokemons", { context in 
        let type: Type? = context.parameter(for: "type")
        presentPokedexListViewController(for: type)
        return true 
    }),
    ("pokedex://pokemons/:pokedexID", { context in 
        guard let pokedexID: Int? = try? context.argument(for: "pokedexID") else {
            // pokedexID must be Int
            return false
        }
        if !Pokedex.isExist(pokedexID) { // Find the Pokémon by ID
            return false
        }
        presentPokedexDetailViewController(of: pokedexID)
        return true 
    }),
    // ...
])

let canRespond25 = router.responds(to: URL(string: "pokedex://pokemons/25")!) // Pikachu(No. 25) is exist! so it returns true
let canRespond9999 = router.responds(to: URL(string: "pokedex://pokemons/9999")!) // No. 9999 is unknown. so it returns false
router.openIfPossible(URL(string: "pokedex://pokemons/25")!) // Open Pikachu page
router.openIfPossible(URL(string: "pokedex://pokemons?type=fire")!) // Open list of fire Pokémons page
```

You can also skip schemes on URLs. URLPattern `/search/:keyword` means `pokedex://search/:keyword` on the router.

In common use case, you should call `router.openIfPossible` on `UIApplicationDelegate` method.

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
    return router.openIfPossible(url, options: options)
}
```

## Argument and Parameter

`:` prefixed components on passed URL pattern mean **argument**.

For example, if passed URL matches `pokedex://search/:keyword`, you can get `keyword` from `Context`.

```swift
// matches: pokedex://search/Pikachu
let keyword: String = try! context.argument(for: "keyword") // Pikachu
```

And more, you can get query parameters if exist.

```swift
// matches: pokedex://search/Pikachu?generation=1
let generation: Int? = context.parameter(for: "generation") // 1
```

Currently supported type is `Int`, `Int64`, `Float`, `Double`, `Bool`, `String` and `URL`.

### Enum argument

You can use enum as arguments by implementing `Extractable`.

```swift
enum Type: String, Extractable {
    case normal
    case fire
    case water
    case grass
    // ....
}

// matches: pokedex://pokemons?type=fire
let type: Type? = context.parameter(for: "type") // .fire
```

### Comma-separated list

You can treat comma-separated query strings as `Array`.

```swift
// matches: pokedex://pokemons?types=water,grass
let types: [Type]? = context.parameter(for: "types") // [.water, .grass]
```

### Custom argument

You can also define own arguments by implementing `Extractable`.
This is an example to parse custom struct.

```swift
struct User {
    let name: String
}
extension User: Extractable {
    static func extract(from string: String) -> User? {
        return User(name: string)
    }
}
```

## Custom Router

You can add any payload to `Router`.

```swift
struct UserInfo {
    let userID: Int64
}
let router = Router<UserInfo>(scheme: "pokedex")
router.register([
    ("pokedex://pokemons", { context in 
        let userInfo: UserInfo = context.userInfo
        let userID = userInfo.userID
        return true
    }),
    // ...
])
let userInfo = UserInfo(userID: User.current.id)
router.openIfPossible(url, userInfo: userInfo)
```

## Universal Links

You can make routers handle with Universal Links.

Of course, you can also use [Firebase Dynamic Link](https://firebase.google.com/docs/dynamic-links) or other similar services.

```swift
let router = DefaultRouter(url: URL(string: "https://my-awesome-pokedex.com")!)
```

## Supported version

Latest version of Crossroad requires Swift 5.0 or above.

Use 1.x instead on Swift 4.1 or lower.

|Crossroad Version|Swift Version|Xcode Version|
|-----------------|-------------|-------------|
|2.x              |5.0          |Xcode 10.2   |
|1.x              |4.0 ~ 4.2    |~ Xcode 10.1  |

## License

Crossroad is released under the MIT License.

Header logo is released under the [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) license. Original design by [@Arslanshn](https://github.com/Arslanshn).
