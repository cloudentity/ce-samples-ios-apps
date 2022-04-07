import SwiftUI

struct ScopesView: View {
    @EnvironmentObject var modelData: ModelData
    @State private var alertVisible = false
    @State private var currentResource: ScopeResource?
    var scopes: [String] = []
    
    init(scopes: String?) {
        if let scopes = scopes {
            self.scopes = scopes.components(separatedBy: " ")
        }
    }
    
    var scopeResourceButtons: [ScopeResource] {
        modelData.scopeResources.filter { self.scopes.contains($0.scope)}
    }
    
    var body: some View {
        VStack {
            if modelData.scopeResources.isEmpty {
                Text("Error getting scopes from JWT!")
            } else {
                ForEach(modelData.scopeResources, id: \.self) { scope in
                    NavigationLink(scope.title, destination: ResourceView(URL(string: scope.url)!))
                        .frame(width: 160, height: 20, alignment: .center)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(30)
                }
                Spacer()
            }
        }
    }
}

struct ScopesView_Previews: PreviewProvider {
    static var previews: some View {
        ScopesView(scopes: "profile email")
            .environmentObject(ModelData())
    }
}
