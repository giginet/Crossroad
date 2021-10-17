import SwiftUI

struct PokemonDetailView: View {
    @State var pokemon: Pokemon

    var body: some View {
        Text(pokemon.name)
    }
}

struct PokemonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonDetailView(pokemon: ピカチュウ)
    }
}
