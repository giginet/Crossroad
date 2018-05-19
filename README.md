# Crossroad

Route URL schemes easily.

## Basic Usage

You can use `DefaultRouter` to define route definitions.

Imagine to implement Pokédex on iOS. You can access somewhere via URL scheme.

```swift
router = DefaultRouter(scheme: "pokemon")
router.register(routes: [
    ("pokedex://pokemons", { context in 
        let type: Type? = context.parameters(for: "type")
        presentPokedexListViewController(for: type)
        return true 
    }),
    ("pokedex://pokemons/:pokedexID", { context in 
        guard let pokedexID: Int = try? context.pokedexID else {
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

let canRespond25 = router.responds(URL(string: "pokedex://pokemons/25")!) // Pikachu(No. 25) is exist! so it returns true
let canRespond9999 = router.responds(URL(string: "pokedex://pokemons/9999")!) // No. 9999 is unknown. so it returns false
router.openIfPossible(to: URL(string: "pokedex://pokemons/25")) // Open Pikachu page
router.openIfPossible(to: URL(string: "pokedex://pokemons?type=fire")) // Open list of fire Pokémons page
```

In general usecase, you should call `router.openIfPossible` on `UIApplicationDelegate` method.

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
let keyword: Keyword = try! context.argument(for: "keyword") // Pikachu
```

And more, you can get query parameters if exist.

```swift
// matches: pokedex://seaches/Pikachu?generation=1
let generation: Int = context.parameter(for: "generation") // 1
```

Currently supported type is `Int`, `Int64`, `Float`, `Double`, `Bool`, `String`, `URL`.

### Custom argument

You can define custom argument by inheriting `Argument`.

```swift
enum Type: Argument {
    case .normal
    case .fire
    case .water
    case .grass
    // ....
}

// matches: pokedex://pokemons?type=fire
let type: Type = context.parameter(for: "type") // .fire
```

### Comma separated list

You can treat comma separated query string as `Arary`.

```
// matches: pokedex://pokemons?types=water,grass
let types: [Type] = context.parameter(for: "types") // [.water, .grass]
```

### And more

You can define own argument by inheriting `Argument`.

## Custom Router

You can add any payload to `Router`.

```swift
struct UserInfo {
    let userID: Int64
}
let router = Router<UserInfo>(scheme: "pokedex")
router.register(routes: [
    ("pokedex://pokemons", { context in 
        let userInfo: UserInfo = context.userInfo
        let userID = userInfo.userID
        return true 
    }),
    // ...
])
let userInfo = UserInfo(userID: User.current.id)
router.openIfPossible(to: url, userInfo: userInfo)
```
