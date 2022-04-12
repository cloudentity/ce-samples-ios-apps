import SwiftUI

struct HomeView: View {
    @EnvironmentObject  var modelData: ModelData
    @State private var selection: Tab = .payload
    
    enum Tab: String {
        case scopes = "Resources"
        case payload = "Payload"
        case header = "Header"
    }
    
    var body: some View {
        TabView(selection: $selection) {
            Text(modelData.tokenResponse?.decodedPayload() ?? "Error getting payload")
                .tabItem {
                    Label("Payload", systemImage: "tray.circle")
                }
                .tag(Tab.payload)

            Text(modelData.tokenResponse?.decodedHeader() ?? "Error getting header")
                .tabItem {
                    Label("Header", systemImage: "pencil.tip")
                }
                .tag(Tab.header)
            ScopesView(modelData: modelData)
                .tabItem {
                    Label("Resources", systemImage: "icloud.and.arrow.up.fill")
                }
                .tag(Tab.scopes)
        }
        .padding()
        .navigationTitle(selection.rawValue)
       
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
