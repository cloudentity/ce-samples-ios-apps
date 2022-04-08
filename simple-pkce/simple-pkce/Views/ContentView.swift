import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @State private var selection: Tab = .payload
    
    enum Tab: String {
        case scopes = "Resources"
        case payload = "Payload"
        case header = "Header"
    }
    
    var body: some View {
            NavigationView {
                VStack {
                    if store.err != nil {
                        VStack {
                            Text(store.err!.localizedDescription)
                            Button("Log out") {
                                store.updateAuthenticated(res: nil, err: nil)
                            }.foregroundColor(.red).padding()
                        }
                    } else {
                        TabView(selection: $selection) {
                            TokenSegmentView(data: store.jwt?.decodedPayload())
                                .tabItem {
                                    Label("Payload", systemImage: "tray.circle")
                                }
                                .tag(Tab.payload)
                            
                            TokenSegmentView(data: store.jwt?.decodedHeader())
                                .tabItem {
                                    Label("Header", systemImage: "pencil.tip")
                                }
                                .tag(Tab.header)
                            ScopesView(scopes: store.claims)
                                .tabItem {
                                    Label("Resources", systemImage: "icloud.and.arrow.up.fill")
                                }
                                .tag(Tab.scopes)
                            
                        }
                        .padding()
                        .navigationTitle(selection.rawValue)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Logout") {
                                    store.updateAuthenticated(res: nil, err: nil)
                                }
                                .foregroundColor(.black)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .ignoresSafeArea()
                .background(AppTheme.backgroundColor)
        }
        
    }
}


