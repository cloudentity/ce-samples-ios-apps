//
//  APIService.swift
//  simple-pkce
//
//  Created by Billy Bray on 4/5/22.
//

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
}