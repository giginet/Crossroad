import SwiftUI

struct MyButton: View {
    private let action: () -> Void
    private let text: String

    init(_ text: String, action: @escaping () -> Void) {
        self.action = action
        self.text = text
    }

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.largeTitle)
                .foregroundColor(.blue)
        }.overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.blue, lineWidth: 1)
        )
    }
}

struct TopView: View {
    @Environment(\.application) var application: UIApplication!

    var body: some View {
        VStack {
            Text("Crossroad Demo")
            MyButton("Open Pokemon Details") {
                if application.canOpenURL(URL(string: "pokedex://pokemons/25")!) {
                    application.open(URL(string: "pokedex://pokemons/25")!,
                                      options: [:],
                                      completionHandler: nil)
                    }
            }
            .padding()
            MyButton("Open Search") {
                application.open(URL(string: "pokedex://pokemons/search?types=water,grass&region=hoenn")!,
                                  options: [:],
                                  completionHandler: nil)
            }
            .padding()
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
