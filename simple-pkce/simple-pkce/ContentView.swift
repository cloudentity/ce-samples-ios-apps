import SwiftUI

struct ContentView: View {
    @EnvironmentObject  var modelData: ModelData

    var body: some View {
        ZStack {
            if modelData.tokenResponse != nil {
                NavigationView {
                    HomeView()
                        .toolbar {
                            Button(action: {
                                modelData.tokenResponse = nil
                            }) {
                               Image(systemName: "rectangle.portrait.and.arrow.right")
                            }
                        }
                }
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
