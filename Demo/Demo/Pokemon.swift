import Foundation
import Crossroad

struct Pokemon {
    enum PokemonType: String, Parsable {
        case normal
        case fire
        case water
        case grass
        case electric
        case ice
        case fighting
        case poison
        case ground
        case flying
        case phychic
        case bug
        case rock
        case ghost
        case dark
        case dragon
        case steel
        case fairy
    }

    enum Region: String, Parsable {
        case kanto
        case johto
        case hoenn
        case sinnoh
        case unova
        case kalos
        case alola
        case galar
    }

    var id: Int
    var name: String
    var type1: PokemonType
    var type2: PokemonType?
    var region: Region
}

struct Pokedex {
    let pokemons: [Pokemon] = [
        ピカチュウ
    ]

    func pokemon(for id: Int) -> Pokemon? {
        pokemons.first { $0.id == id }
    }
}

let ピカチュウ: Pokemon = .init(id: 25, name: "Pikachu", type1: .electric, type2: nil, region: .kanto)
