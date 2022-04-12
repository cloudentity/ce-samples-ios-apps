import Foundation
import CryptoKit

final class CodeGenerator {
    private var verifier: String = ""
    
    func getVerifier() -> String {
        if verifier.isEmpty {
            fatalError("verifier empty")
        }
        return verifier
    }

    func getChallenge() -> String {
        let challenge = verifier
            .data(using: .ascii)
            .map { SHA256.hash(data: $0) }
            .map { base64URLEncode(octets: $0) }

        if let challenge = challenge {
            return challenge
        } else {
            fatalError("failed to generate challenge")
        }
    }
    
    func generateVerifier() {
        var buffer = [UInt8](repeating: 0, count: 32)
        let status = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        if status != errSecSuccess {
            fatalError("failed to generate verifier")
        }
        
        verifier = Data(buffer).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
    }

    private func base64URLEncode<S>(octets: S) -> String where S : Sequence, UInt8 == S.Element {
        let data = Data(octets)
        return data
            .base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .trimmingCharacters(in: .whitespaces)
    }
}


