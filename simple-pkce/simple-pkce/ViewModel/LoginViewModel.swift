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
                        completion(nil, err)
                    }
                }
            }
        }
    }
}
