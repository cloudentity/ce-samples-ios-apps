import AuthenticationServices

final class Authenticator: NSObject, ASWebAuthenticationPresentationContextProviding {
    private var codeGenerator = CodeGenerator()
    let completion: (TokenResponse?, AuthError?) -> Void

    init(completion: @escaping (TokenResponse?, AuthError?) -> Void) {
        self.completion = completion
    }

    func authenticate() {
        codeGenerator.generateVerifier()
        
        guard let authURL = URL(string: AuthConfig.authEndpoint)?.getAuthURL(clientID: AuthConfig.clientID, challenge: codeGenerator.getChallenge(), urlScheme: AuthConfig.urlScheme) else {
            self.completion(nil, .failedToSetAuthURL)
            return
        }

        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "oauth")
        { [self] callbackURL, error in
            
            guard error == nil else {
                self.completion(nil, .cancelled)
                return
            }

            guard let callbackURL = callbackURL else {
                self.completion(nil, .callbackMissingCallbackURL)
                return
            }
            
            guard callbackURL.getQueryParam(value: "error") == nil else {
                self.completion(nil, .errorReturnedFromAuthorize(callbackURL.getQueryParam(value: "error")!))
                return
            }
            
            guard let code = callbackURL.getQueryParam(value: "code") else {
                self.completion(nil, .callbackMissingCode)
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
            self.completion(nil, .failedToGetTokenEndpoint)
            return
        }
        
        let verifier = self.codeGenerator.getVerifier()
        let request = url.getTokenRequest(clientID: AuthConfig.clientID, verifier: verifier, code: code, urlScheme: AuthConfig.urlScheme)
        
        URLSession.shared.dataTask(with: request) { [weak self]
            data,_,err in
            if err != nil {
                self?.completion(nil, .tokenRequestFailed(err!))
                return
            }
            
            DispatchQueue.main.async {
                guard let data = data else {
                    self?.completion(nil, .unableToParseTokenResponse)
                    return
                }
                do {
                    let v = try JSONDecoder().decode(TokenResponse.self, from: data)
                    self?.completion(v, nil)
                } catch {
                    self?.completion(nil, .unableToParseTokenResponse)
                }
            }
        }.resume()
    }
}

extension Authenticator {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    
    static func refreshToken(refreshToken: String, completion: @escaping (TokenResponse?, AuthError?) -> Void) {
        
        guard let url = URL(string: AuthConfig.tokenEndpoint) else {
            completion(nil, .failedToGetTokenEndpoint)
            return
        }
        
        let request = url.getRefreshToken(clientID: AuthConfig.clientID, token: refreshToken, urlScheme: AuthConfig.urlScheme)
        URLSession.shared.dataTask(with: request) { data,res,err in

            if err != nil {
                completion(nil, .tokenRequestFailed(err!))
                return
            }
            guard let data = data else {
                completion(nil, .unableToParseTokenResponse)
                return
            }
            do {
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                let v = try JSONDecoder().decode(TokenResponse.self, from: data)
                completion(v, nil)
            } catch  {
                completion(nil, .unableToParseTokenResponse)
            }
        }.resume()
    }
}
