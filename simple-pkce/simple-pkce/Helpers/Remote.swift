import Foundation

struct LoadingError: Error {}

final class Remote<A>: ObservableObject {
    @Published var result: Result<A, AuthError>? = nil
    var value: A? { try? result?.get() }
    var modelData: ModelData
    
    let url: URL
    let transform: (Data) -> A?

    init(modelData: ModelData, url: URL, transform: @escaping (Data) -> A?) {
        self.url = url
        self.transform = transform
        self.modelData = modelData
    }

    func load() {
        let request = self.getRequest(url: self.url)
        
        URLSession.shared.dataTask(with: request) { data, res, err in
            DispatchQueue.main.async { [weak self] in
                if let d = data, let v = self?.transform(d) {
                    self?.result = .success(v)
                } else {
                    if let httpResponse = res as? HTTPURLResponse {
                        if httpResponse.statusCode == 403 {
                            if let refreshToken = self?.modelData.tokenResponse?.refreshToken, !refreshToken.isEmpty {
                                Authenticator.refreshToken(refreshToken: refreshToken, completion: { res, err in
                                    DispatchQueue.main.async {
                                        if err != nil {
                                            self?.modelData.setToken(token: nil)
                                            return
                                        } else {
                                            self?.modelData.setToken(token: res)
                                            self?.load()
                                        }
                                    }
                                })
                            } else {
                                self?.result = .failure(AuthError.resourceError("\(httpResponse.statusCode)"))
                            }
                        } else {
                            self?.result = .failure(AuthError.resourceError("\(httpResponse.statusCode)"))
                        }
                        return
                    }
                    var errorMessage = ""
                    if let err = err {
                        errorMessage = err.localizedDescription
                    }
                    self?.result = .failure(AuthError.resourceError(errorMessage))
                }
            }
        }.resume()
    }
}

extension Remote {
    func getRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: self.url)
        request.httpMethod = "GET"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let token = self.modelData.tokenResponse?.accessToken {
            request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}

