import SwiftUI

@main
struct simple_pkceApp: App {
    @StateObject var store = Store()
    var body: some Scene {
        WindowGroup {
            if store.isAuthenticated {
                ContentView()
                    .environmentObject(store)
            } else {
                LoginView()
                    .environmentObject(store)
            }
        }
    }
}
