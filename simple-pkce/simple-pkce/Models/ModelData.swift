import Foundation

final class ModelData: ObservableObject {
    @Published var scopeResources: [ScopeResource] = load("scopeData.json")
    @Published var tokenResponse: TokenResponse?
    let theme: Theme = Theme.main
    
    func setToken(token: TokenResponse?) {
        var encodedData: Data?
        do {
            encodedData = try JSONEncoder().encode(token)
        } catch {
            KeychainHelper.shared.delete()
            return
        }
        
        guard let data = encodedData, let jsonString = String(data: data,
                                      encoding: .utf8) else {
            KeychainHelper.shared.delete()
            return
        }

        KeychainHelper.shared.update(token: jsonString)

        self.tokenResponse = token
    }
    
    private func checkStored() {
        guard let tokenResp = fetchStoredToken() else {
            return
        }

        self.tokenResponse = tokenResp
    }
    
    private func fetchStoredToken() -> TokenResponse? {
        var tokenResponse: TokenResponse?
        if let token = KeychainHelper.shared.get(){
            do {
                print("found trying \(token)")
                tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: Data(token.utf8))
            } catch {
                print("found failing")

                tokenResponse = nil
            }
        }
        return tokenResponse
    }
}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
