import Foundation

enum AuthError: LocalizedError {
    case failedToSetAuthURL
    case authRequestFailed(Error)
    case callbackMissingCallbackURL
    case errorReturnedFromAuthorize(String)
    case callbackMissingCode
    case failedToGetTokenEndpoint
    case tokenRequestFailed(Error)
    case unableToParseTokenResponse

    var localizedDescription: String {
        switch self {
        case .failedToSetAuthURL:
            return "failed to set authorization URL"
        case .authRequestFailed(let error):
            return "authorization request failed: \(error.localizedDescription)"
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
