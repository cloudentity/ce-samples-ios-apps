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
        DispatchQueue.main.async {
            APIService().fetchResource(url: self.url, token: self.token) { data, res, err in
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
                    self.result = .failure(AuthError.resourceError("unknown error \(errorMessage)"))
                }
            }
        }
    }
}
