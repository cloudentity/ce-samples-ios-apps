import SwiftUI

@main
struct simple_pkceApp: App {
    @StateObject var authentication = Authentication()
    @StateObject private var modelData = ModelData()
    var body: some Scene {
        WindowGroup {
            if authentication.isAuthenticated {
                ContentView()
                    .environmentObject(authentication)
                    .environmentObject(modelData)
            } else {
                LoginView()
                    .environmentObject(authentication)
            }
        }
    }
}
