import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authentication: Authentication
    @State private var selection: Tab = .payload
    
    enum Tab: String {
        case scopes = "Scopes"
        case payload = "Payload"
        case header = "Header"
    }
    
    var body: some View {
        NavigationView {
            if authentication.err != nil {
                VStack {
                    Text(authentication.err!.localizedDescription)
                    Button("Log out") {
                        authentication.updateAuthenticated(res: nil, err: nil)
                    }.foregroundColor(.red).padding()
                }
            } else {
                TabView(selection: $selection) {
                    TokenSegmentView(data: authentication.jwt?.decodedPayload())
                        .tabItem {
                            Label("Payload", systemImage: "tray.circle")
                        }
                        .tag(Tab.payload)
                    
                    TokenSegmentView(data: authentication.jwt?.decodedHeader())
                        .tabItem {
                            Label("Header", systemImage: "pencil.tip")
                        }
                        .tag(Tab.header)
                    ScopesView(scopes: authentication.claims)
                        .tabItem {
                            Label("Scopes", systemImage: "person.crop.circle")
                        }
                        .tag(Tab.scopes)
                    
                }
                .padding()
                .navigationTitle(selection.rawValue)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Logout") {
                            authentication.updateAuthenticated(res: nil, err: nil)
                        }
                    }
                }
            }
        }
    }
}


