//
//  KeyStore.swift
//  simple-pkce
//
//  Created by Billy Bray on 4/5/22.
//

import Foundation

// TODO - implement Keystore and biometric sign in
class KeyStore {
    
    // TODO - make static methods - no need for instance
    // return bool now, should return error
    func store(key: String, value: String) -> Bool {
//        let tag = key.data(using: .utf8)!
        let addquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: key,
                                       kSecValueData as String: value as AnyObject]
        
        let status = SecItemAdd(addquery as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("error could throw")
            return false
        }
        return true
    }
    
    
//    func getToken(key: String) -> String {
//        let getquery: [String: Any] = [kSecClass as String: kSecClassKey,
//                                       kSecAttrApplicationTag as String: key,
//                                       kSecReturnData as String: kCFBooleanTrue
//        return ""
//    }
}
