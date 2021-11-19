import SwiftUI

struct PokemonDetailView: View {
    @State var pokemon: Pokemon

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(String(pokemon.id))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(pokemon.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding()
            HStack {
                Text(pokemon.type1.rawValue)
                Text(pokemon.type2?.rawValue ?? "")
            }
            Text(pokemon.region.rawValue)
            Spacer()
        }
    }
}

struct PokemonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonDetailView(pokemon: ピカチュウ)
    }
}
