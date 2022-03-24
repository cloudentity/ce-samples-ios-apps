import Foundation

struct TokenResponse: Codable {
    let accessToken: String
    let expiresIn: Int
    let idToken, scope, tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case idToken = "id_token"
        case scope
        case tokenType = "token_type"
    }
}
