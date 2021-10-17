import SwiftUI
import Crossroad

struct PokemonSearchView: View {
    struct Query {
        var types: Set<Pokemon.PokemonType>?
        var region: Pokemon.Region?
    }
    @State var query: Query

    var body: some View {
        HStack {
            Text(queryTypesString)
            Text(query.region?.rawValue ?? "")
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
