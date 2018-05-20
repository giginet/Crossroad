# Crossroad

[![Build Status](https://travis-ci.org/giginet/Crossroad.svg?branch=master)](https://travis-ci.org/giginet/Crossroad)
[![Language](https://img.shields.io/badge/language-Swift%204.1-orange.svg)](https://swift.org)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 

Route URL schemes easily.

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
        guard let pokedexID: Int = try? context.argument(for: "pokedexID") else {
            // pokedexID must be Int
            return false
        }
        if !Pokedex.isExist(pokedexID) { // Find the Pokémon by ID
            return false
        }
        presentPokedexDetailViewController(for: pokedex)
        return true 
    }),
    // ...
])

let canRespond25 = router.responds(to: URL(string: "pokedex://pokemons/25")!) // Pikachu(No. 25) is exist! so it returns true
let canRespond9999 = router.responds(to: URL(string: "pokedex://pokemons/9999")!) // No. 9999 is unknown. so it returns false
router.openIfPossible(URL(string: "pokedex://pokemons/25")) // Open Pikachu page
router.openIfPossible(URL(string: "pokedex://pokemons?type=fire")) // Open list of fire Pokémons page
```

In common usecase, you should call `router.openIfPossible` on `UIApplicationDelegate` method.

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
    router.openIfPossible(url, options: options)
}
```

## Argument and Parameter

`:` prefixed components on passed URL pattern mean **argument**.

For example, if passed URL matches `pokedex://search/:keyword`, you can get `keyword` from `Context`.

```swift
// matches: pokedex://seaches/Pikachu
let keyword: String = try! context.argument(for: "keyword") // Pikachu
```

And more, you can get query parameters if exist.

```swift
// matches: pokedex://searche/Pikachu?generation=1
let generation: Int = context.parameter(for: "generation") // 1
```

Currently supported type is `Int`, `Int64`, `Float`, `Double`, `Bool`, `String` and `URL`.

### Enum argument

You can use enum as arguments by implementing `Argument`.

```swift
enum Type: String, Argument {
    case normal
    case fire
    case water
    case grass
    // ....
}

// matches: pokedex://pokemons?type=fire
let type: Type = context.parameter(for: "type") // .fire
```

### Comma-separated list

You can treat comma-separated query strings as `Array`.

```swift
// matches: pokedex://pokemons?types=water,grass
let types: [Type] = context.parameter(for: "types") // [.water, .grass]
```

### Custom argument

You can also define own arguments by implementing `Argument`.
This is an example to parse regular expressions.

```swift
extension NSRegularExpression: Argument {
    init?(string: String) {
        self = try? NSRegularExpression(pattern: string, options: .caseInsensitive)
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
