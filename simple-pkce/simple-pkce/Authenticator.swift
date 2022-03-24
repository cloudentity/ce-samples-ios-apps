import AuthenticationServices

struct AuthConfig {
    static let clientID = ""
    static let tokenEndpoint = ""
    static let authEndpoint = ""
    static let urlScheme = "oauth://com.example.simple-pkce"
}

final class Authenticator: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    @Published var result: Result<TokenResponse, AuthError>? = nil
    private var verifier = CodeGenerator()
    var value: TokenResponse? { try? result?.get()}
    let transform: (Data)->TokenResponse?
    
    init(transform: @escaping(Data)->TokenResponse?) {
        self.transform = transform
    }

    func authenticate() {
        verifier.generateNewVerifier()
        
        guard let authURL = URL(string: AuthConfig.authEndpoint)?.getAuthURL(clientID: AuthConfig.clientID, challenge: verifier.getChallenge(), urlScheme: AuthConfig.urlScheme) else {
            self.result = .failure(.failedToSetAuthURL)
            return
        }

        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "oauth")
        { [self] callbackURL, error in
            
            guard error == nil else {
                self.result = .failure(.authRequestFailed(error!))
                return
            }

            guard let callbackURL = callbackURL else {
                self.result = .failure(.callbackMissingCallbackURL)
                return
            }
            
            guard callbackURL.getQueryParam(value: "error") == nil else {
                print(callbackURL)
                self.result = .failure(.errorReturnedFromAuthorize(callbackURL.getQueryParam(value: "error")!))
                return
            }
            
            guard let code = callbackURL.getQueryParam(value: "code") else {
                self.result = .failure(.callbackMissingCode)
                return
            }

            self.fetchToken(code: code)
        }
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true
        session.start()
    }
    
    private func fetchToken(code: String) {
        guard let url = URL(string: AuthConfig.tokenEndpoint) else {
            self.result = .failure(.failedToGetTokenEndpoint)
            return
        }
        
        let verifier = self.verifier.getCodeVerifier()
        let request = url.getTokenRequest(clientID: AuthConfig.clientID, verifier: verifier, code: code, urlScheme: AuthConfig.urlScheme)
        
        URLSession.shared.dataTask(with: request) {
            data,_,err in
            if err != nil {
                self.result = .failure(.tokenRequestFailed(err!))
                return
            }
            
            DispatchQueue.main.async {
                if let d = data, let v = self.transform(d) {
                    self.result = .success(v)
                } else {
                    self.result = .failure(.unableToParseTokenResponse)
                }
            }
        }.resume()
    }
}

extension Authenticator {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
