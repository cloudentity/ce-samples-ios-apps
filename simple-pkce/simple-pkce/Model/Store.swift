import SwiftUI

class Store: ObservableObject {
    @Published var scopeResources: [ScopeResource] = load("scopeData.json")
    @Published var jwt: JWT?
    @Published var claims: String?
    @Published var err: AuthError?
    
    var isAuthenticated: Bool {
        jwt != nil
    }

    func updateAuthenticated(res: TokenResponse?, err: AuthError?) {
        withAnimation {
            if err != nil{
                self.jwt = nil
                self.claims = nil
                self.err = err
                return
            }
            
            if let res = res {
                self.err = nil
                self.jwt = JWT(token: res.accessToken)
                self.claims = res.scope
            } else {
                self.jwt = nil
            }
        }
    }
}
