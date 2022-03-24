import SwiftUI

struct TokenView: View {
    @ObservedObject var tokenResponse = Authenticator(transform: { try? JSONDecoder().decode(TokenResponse.self, from: $0)})
    
    init() {
        tokenResponse.authenticate()
    }

    var body: some View {
        VStack {
            switch tokenResponse.result {
            case .success(let tokenResponse):
                ScrollView {
                    Text(tokenResponse.accessToken).padding().font(.system(size: 12)).background(.white)
                }.cornerRadius(30).navigationBarTitle("Access Token")
            case .failure(let error):
                Text(error.localizedDescription).foregroundColor(.white)
            case .none:
                ProgressView().accentColor(.white)
            }
        }.foregroundColor(.black)
    }
}

struct ContentView: View {
    var body: some View {
        ZStack {
            NavigationView {
                NavigationLink(destination: NavigationLazyView(TokenView())) {
                    VStack {
                        Image("white").resizable().scaledToFit().frame(width: 250).padding()
                        HStack {
                                Image(systemName: "person.circle")
                                    .font(.title)
                                Text("Sign In")
                                    .fontWeight(.semibold)
                                    .font(.title2)
                            }.frame(width: 160, height: 20, alignment: .center)
                            .padding()
                            .foregroundColor(.black)
                            .background(Color.white)
                            .cornerRadius(30)
                    }
                }
            }
        }.preferredColorScheme(.dark).accentColor(.white)
    }
}

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }
}
