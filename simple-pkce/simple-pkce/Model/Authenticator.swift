import AuthenticationServices

final class Authenticator: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    private var codeGenerator = CodeGenerator()
    let transform: (Data)->TokenResponse?
    let completion: (Result<TokenResponse, AuthError>) -> Void
    
    init(transform: @escaping(Data)->TokenResponse?, completion: @escaping (Result<TokenResponse, AuthError>) -> Void) {
        self.transform = transform
        self.completion = completion
    }

    func authenticate() {
        codeGenerator.generateVerifier()
        
        guard let authURL = URL(string: AuthConfig.authEndpoint)?.getAuthURL(clientID: AuthConfig.clientID, challenge: codeGenerator.getChallenge(), urlScheme: AuthConfig.urlScheme) else {
            completion(.failure(.failedToSetAuthURL))
            return
        }

        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "oauth")
        { [self] callbackURL, error in
            
            guard error == nil else {
                completion(.failure(.authRequestFailed(error!)))
                return
            }

            guard let callbackURL = callbackURL else {
                completion(.failure(.callbackMissingCallbackURL))
                return
            }
            
            guard callbackURL.getQueryParam(value: "error") == nil else {
                completion(.failure(.errorReturnedFromAuthorize(callbackURL.getQueryParam(value: "error")!)))
                return
            }
            
            guard let code = callbackURL.getQueryParam(value: "code") else {
                completion(.failure(.callbackMissingCode))
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
            completion(.failure(.failedToGetTokenEndpoint))
            return
        }
        
        let verifier = self.codeGenerator.getVerifier()
        let request = url.getTokenRequest(clientID: AuthConfig.clientID, verifier: verifier, code: code, urlScheme: AuthConfig.urlScheme)
        
        URLSession.shared.dataTask(with: request) { [unowned self]
            data,_,err in
            if err != nil {
                completion(.failure(.tokenRequestFailed(err!)))
                return
            }
            
            if let d = data, let v = self.transform(d) {
                completion(.success(v))
            } else {
                completion(.failure(.unableToParseTokenResponse))
            }
        }.resume()
    }
}

extension Authenticator {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
