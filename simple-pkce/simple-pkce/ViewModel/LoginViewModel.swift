//
//  AuthenticateViewModel.swift
//  simple-pkce
//
//  Created by Billy Bray on 4/5/22.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var showProgress = false
    
    func login(completion: @escaping (TokenResponse?, AuthError?) -> Void) {
        showProgress = true
        
        APIService.shared.login() { result in
            withAnimation {
                DispatchQueue.main.async { [unowned self] in
                    showProgress = false
                    switch result {
                    case .success(let res):
                        completion(res, nil)
                    case .failure(let err):
                        print("failed login \(err)")
                        completion(nil, err)
                    }
                }
            }
        }
    }
}
