import SwiftUI
import Crossroad

extension Pokemon: Identifiable {
    
}

struct PokemonSearchView: View {
    struct Query {
        var types: Set<Pokemon.PokemonType>?
        var region: Pokemon.Region?
    }
    @State var query: Query
    
    var pokemons: [Pokemon] {
        Pokedex().pokemons.filter { pokemon in
            pokemon.types.isSuperset(of: query.types ?? [])
            && (query.region == nil || pokemon.region == query.region)
        }
        .sorted(by: { $0.id < $1.id })
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Pokedex")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                List(pokemons) { pokemon in
                    NavigationLink(destination: PokemonDetailView(pokemon: pokemon)) {
                        Text("\(pokemon.id) \(pokemon.name)")
                    }
                }
                Spacer()
            }
        }
    }
    
    var queryTypesString: String {
        let types = query.types?.compactMap { $0.rawValue } ?? []
        return types.joined(separator: ",")
    }
}

struct PokemonSearchView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonSearchView(query: PokemonSearchView.Query())
    }
}
