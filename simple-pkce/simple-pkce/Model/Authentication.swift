import SwiftUI

class Authentication: ObservableObject {
    @Published var jwt: JWT?
    @Published var claims: String?
    @Published var err: AuthError?
    
    var isAuthenticated: Bool {
        jwt != nil
    }

    func updateAuthenticated(res: TokenResponse?, err: AuthError?) {
        withAnimation {
            if err != nil{
                self.err = err
                return
            }
            
            if let res = res {
                self.jwt = JWT(token: res.accessToken)
                self.claims = res.scope
            } else {
                self.jwt = nil
            }
        }
    }
}
