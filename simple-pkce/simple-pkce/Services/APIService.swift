import Foundation

class APIService {
    static let shared = APIService()
    
    enum APIError: Error {
        case error
    }
    
    func login(completion: @escaping (Result<TokenResponse, AuthError>) -> Void) {
        Authenticator(transform: { try? JSONDecoder().decode(TokenResponse.self, from: $0)}) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }.authenticate()
    }
    
    func fetchResource(url: URL, token: String?, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let token = token {
            request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, res, err in
            completion(data, res, err)
        }.resume()
    }
}
