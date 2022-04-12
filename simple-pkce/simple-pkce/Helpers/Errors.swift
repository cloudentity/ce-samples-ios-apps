import Foundation

enum AuthError: LocalizedError {
    case resourceError(String)
    case unknown
    case failedToSetAuthURL
    case cancelled
    case callbackMissingCallbackURL
    case errorReturnedFromAuthorize(String)
    case callbackMissingCode
    case failedToGetTokenEndpoint
    case tokenRequestFailed(Error)
    case unableToParseTokenResponse

    var localizedDescription: String {
        switch self {
        case .resourceError(let status):
            return "error: \(status)"
        case .unknown:
            return "error unknown"
        case .failedToSetAuthURL:
            return "failed to set authorization URL"
        case .cancelled:
            return "cancelled login"
        case .callbackMissingCallbackURL:
            return "authorization response does not include the callback URL"
        case .errorReturnedFromAuthorize(let message):
            return "error returned from authorization request \(message)"
        case .callbackMissingCode:
            return "authorization response does not include the code"
        case .tokenRequestFailed(let error):
            return "unable to get token: \(error.localizedDescription)"
        case .unableToParseTokenResponse:
            return "unable to parse token response"
        case .failedToGetTokenEndpoint:
            return "unable to get token endpoint - check the URL is correct and set in AuthClientConfig"
        }
    }
}

enum ScopeResourceError: Error {
    case networkFailure(Error)
    case authError(Error)
    case badURL
}
