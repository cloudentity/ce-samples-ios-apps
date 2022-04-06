import Foundation

struct JWT {
    private let accessToken: String
    
    init(token: String) {
        self.accessToken = token
    }

    func getRawToken() -> String {
        return self.accessToken
    }
    
    func decodedPayload() -> String? {
        return decodeSegment(segment: .Payload)
    }
    
    func decodedHeader() -> String? {
        return decodeSegment(segment: .Header)
    }
    
    private func decodeSegment(segment: Segment) -> String? {
        base64Decode(getTokenSegments()[segment.rawValue])?.prettyJson
    }
    
    private func base64Decode(_ base64: String) -> Data? {
        let base64 = base64
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padded = base64.padding(toLength: ((base64.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
        guard let decoded = Data(base64Encoded: padded) else {
            return nil
        }
        return decoded
    }
    
    private func decodeJWTPart(_ value: String) ->  [String: Any]? {
        guard let bodyData = base64Decode(value) else {
            return nil
        }

        guard let json = try? JSONSerialization.jsonObject(with: bodyData, options: []) else {
            return nil
        }

        guard let payload = json as? [String: Any] else {
            return  nil
        }
        return payload
    }
    
    private func getTokenSegments() -> [String] {
        return self.accessToken.components(separatedBy: ".")
    }
    
    private func decodeAccessTokenSegment(segment: Segment) ->  [String: Any]? {
        return decodeJWTPart(getTokenSegments()[segment.rawValue])
    }
}

extension JWT {
    enum Segment: Int {
        case Header = 0
        case Payload = 1
        case Signature = 2
    }
}
