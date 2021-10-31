import SwiftUI

struct TopView: View {
    @Environment(\.application) var application: UIApplication!
    
    private struct Link: View {
        @State var destination: String
        @Environment(\.application) var application: UIApplication!
        
        private var destinationURL: URL? {
            URL(string: destination)
        }
        
        init(placeholder: String) {
            self.destination = placeholder
        }
        
        
        private func open(_ url: URL) {
            application.open(url, options: [:], completionHandler: nil)
        }
        
        var body: some View {
            HStack {
                TextEditor(text: $destination)
                    .lineLimit(3)
                    .frame(minHeight: 30)
                Button("Go!") {
                    if let url = destinationURL {
                        open(url)
                    }
                }
            }
            .padding()
            .border(.gray, width: 2)
            .cornerRadius(4)
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 2, trailing: 8))
        }
    }
    
    var body: some View {
        VStack {
            Text("Crossroad Demo")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            ScrollView {
                VStack {
                    Link(placeholder: "pokedex://pokemons/25")
                        .environment(\.application, application)
                    Link(placeholder: "pokedex://pokemons/search")
                        .environment(\.application, application)
                    Link(placeholder: "pokedex://pokemons/search?types=water")
                        .environment(\.application, application)
                    Link(placeholder: "pokedex://pokemons/search?region=kanto")
                        .environment(\.application, application)
                }
            }
        }
        .frame(alignment: .top)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
