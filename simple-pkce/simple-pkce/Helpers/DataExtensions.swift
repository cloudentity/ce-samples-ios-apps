import Foundation

extension Data {
    var prettyJson: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let jsonAsString = String(data: data, encoding:.utf8) else { return nil }

        return jsonAsString
    }
}
