import Foundation

extension URL {
    
    func getRefreshToken(clientID: String, token: String, urlScheme: String) -> URLRequest {
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name:"client_id", value: clientID),
            URLQueryItem(name:"refresh_token", value: token),
            URLQueryItem(name:"grant_type", value: "refresh_token"),
        ]

        return buildRequest(components: components)
    }
    
    func getTokenRequest(clientID: String, verifier: String, code: String, urlScheme: String) -> URLRequest {
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name:"client_id", value: clientID),
            URLQueryItem(name:"redirect_uri", value: urlScheme),
            URLQueryItem(name:"grant_type", value: "authorization_code"),
            URLQueryItem(name:"code_verifier", value: verifier),
            URLQueryItem(name:"code", value: code),
        ]
        
        return buildRequest(components: components)
    }
    
    func buildRequest(components: URLComponents) -> URLRequest {
        let headers: [String:String] = ["Content-Type": "application/x-www-form-urlencoded"]
        
        var request = URLRequest(url: self)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = components.query?.data(using: .utf8)
        
        return request
    }
    
    func getAuthURL(clientID: String, challenge: String, urlScheme: String) -> URL? {
        guard var components = URLComponents(string: self.absoluteString) else {
            return nil
        }
        
        components.queryItems = [
            URLQueryItem(name:"client_id", value: clientID),
            URLQueryItem(name:"redirect_uri", value: urlScheme),
            URLQueryItem(name:"response_type", value: "code"),
            URLQueryItem(name:"scope", value: "openid accounts balance transfer"),
            URLQueryItem(name:"code_challenge", value: challenge),
            URLQueryItem(name:"code_challenge_method", value: "S256"),
        ]
        
        return components.url
    }
    
    func getQueryParam(value: String) -> String? {
        guard let comps = URLComponents(url: self, resolvingAgainstBaseURL: true), let queryItems = comps.queryItems else { return nil }
        return queryItems.filter ({ $0.name == value }).first?.value
    }
}
