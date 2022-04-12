//
//  KeychainHelper.swift
//  simple-pkce
//
//  Created by Billy Bray on 4/8/22.
//

import Foundation

enum KeychainError: Error {
    case noToken
    case ExpiredToken
    case unhandledError(status: OSStatus)
}

final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}
        
    let server = "www.cloudentity.com"
    let account = "token_response"
    
    func add(token: String) {
        let token = token.data(using: String.Encoding.utf8)!
        
        let query: [String:Any] = [kSecClass as String: kSecClassInternetPassword,
                                   kSecAttrAccount as String: account,
                                kSecAttrServer as String: server,
                                   kSecValueData as String: token]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            // throw KeychainError.unhandledError(status: status)
            print(KeychainError.unhandledError(status: status))
            return
        }
    }
    
    func update(token: String) {
        let query: [String:Any] = [kSecClass as String: kSecClassInternetPassword,
                                   kSecAttrAccount as String: account]
        let attributes: [String:Any] = [kSecValueData as String: token, kSecAttrAccount as String: account]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status != errSecItemNotFound else {
            // throw KeychainError.noPassword
            print("token not found")
            return
        }
        guard status == errSecSuccess else {
            // throw KeychainError.unhandledError(status: status)
            print("failed update \(KeychainError.unhandledError(status: status))")
            return
        }
    }
    
    func delete() {
        let query: [String:Any] = [kSecClass as String: kSecClassInternetPassword,
                                   kSecAttrAccount as String: account]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            // throw KeychainError.unhandledError(status: status)
            print("failed to delete \(KeychainError.unhandledError(status: status))")
            return
        }
    }
    
    func get() -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: server,
                                                                kSecMatchLimit as String: kSecMatchLimitOne,
                                                                kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else {
            // throw KeychainError.noPassword
            // happens on first pass
            print("token not found")
            return nil
        }
        guard status == errSecSuccess else {
            // throw KeychainError.unhandledError(status: status)
            print("failure \(KeychainError.unhandledError(status: status))")
            return nil
        }
        
        guard let existingItem = item as? [String : Any],
            let tokenData = existingItem[kSecValueData as String] as? Data,
            let token = String(data: tokenData, encoding: String.Encoding.utf8),
                let account = existingItem[kSecAttrAccount as String] as? String 
        else {
            // throw KeychainError.unexpectedPasswordData
            print("unexepcted password \(KeychainError.noToken)")
            return nil
        }
        print(account)

        print("got token \(token)")
        return token
    }
    
//    func save(_, data: Data, service: String, accound: String) {
//        let query = [
//        kcev]
//    }
}
