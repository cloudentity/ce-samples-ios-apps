import SwiftUI

struct ScopesView: View {
    @EnvironmentObject var store: Store
    @State private var alertVisible = false
    @State private var currentResource: ScopeResource?
    var scopes: [String] = []
    
    init(scopes: String?) {
        if let scopes = scopes {
            self.scopes = scopes.components(separatedBy: " ")
        }
    }
    
    var scopeResourceButtons: [ScopeResource] {
        store.scopeResources.filter { self.scopes.contains($0.scope)}
    }
    
    var body: some View {
        VStack {
            Spacer()
            if store.scopeResources.isEmpty {
                Text("Error getting scopes from JWT!")
            } else {
                ForEach(store.scopeResources, id: \.self) { scope in
                    NavigationLink(scope.title, destination: ResourceView(URL(string: scope.url)!, token: store.jwt?.getRawToken()))
                        .frame(width: 160, height: 20, alignment: .center)
                        .padding()
                        .foregroundColor(.white)
                        .background(AppTheme.buttonColor)
                        .cornerRadius(30)
                }
                Spacer()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(AppTheme.backgroundColor)
    }
}

struct ScopesView_Previews: PreviewProvider {
    static var previews: some View {
        ScopesView(scopes: "profile email")
            .environmentObject(ModelData())
    }
}
