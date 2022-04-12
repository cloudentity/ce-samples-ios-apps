import SwiftUI

struct ScopesView: View {
    @State private var alertVisible = false
    var modelData: ModelData
    
    var scopeResourceButtons: [ScopeResource] {
        modelData.scopeResources.filter { modelData.tokenResponse?.scope.contains($0.scope) ?? false
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            ForEach(scopeResourceButtons, id: \.self) { scope in
                NavigationLink(scope.title, destination: ResourceView(URL(string: scope.url)!, token: modelData.tokenResponse?.getRawToken()))
                    .frame(width: 160, height: 20, alignment: .center)
                    .padding()
                    .foregroundColor(modelData.theme.accentColor)
                    .background(modelData.theme.mainColor)
                    .cornerRadius(30)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct ScopesView_Previews: PreviewProvider {
    static var previews: some View {
        ScopesView(modelData: ModelData())
    }
}
