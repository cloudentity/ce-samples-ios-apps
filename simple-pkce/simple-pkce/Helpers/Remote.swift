import Foundation

struct LoadingError: Error {}

final class Remote<A>: ObservableObject {
    @Published var result: Result<A, AuthError>? = nil
    var value: A? { try? result?.get() }
    var token: String?
    
    let url: URL
    let transform: (Data) -> A?

    init(token: String?, url: URL, transform: @escaping (Data) -> A?) {
        self.url = url
        self.transform = transform
        self.token = token
    }

    func load() {
        let request = self.getRequest(url: self.url)
        
        URLSession.shared.dataTask(with: request) { data, res, err in
            DispatchQueue.main.async {
                if let d = data, let v = self.transform(d) {
                    print(v)
                    self.result = .success(v)
                } else {
                    if let httpResponse = res as? HTTPURLResponse {
                        self.result = .failure(AuthError.resourceError("\(httpResponse.statusCode)"))
                        return
                    }
                    var errorMessage = ""
                    if let err = err {
                        errorMessage = err.localizedDescription
                    }
                    self.result = .failure(AuthError.resourceError(errorMessage))
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
        if let token = self.token {
            request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}

