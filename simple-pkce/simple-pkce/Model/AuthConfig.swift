import Foundation

struct AuthConfig {
    static let clientID = Bundle.main.object(forInfoDictionaryKey: "ClientID") as! String
    static let tokenEndpoint = Bundle.main.object(forInfoDictionaryKey: "TokenEndpoint") as! String
    static let authEndpoint = Bundle.main.object(forInfoDictionaryKey: "AuthorizeEndpoint") as! String
    static let urlScheme: String = {
        let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? Array<Any>
        let urlTypeDict = urlTypes![0] as! Dictionary<String, Any>
        let scheme = (urlTypeDict["CFBundleURLSchemes"] as! Array<String>)[0]
        return "\(scheme)://\(urlTypeDict["CFBundleURLName"] as! String)"
    }()
}
