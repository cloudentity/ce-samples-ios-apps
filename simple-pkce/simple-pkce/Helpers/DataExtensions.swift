//
//  DateExtensions.swift
//  simple-pkce
//
//  Created by Billy Bray on 4/5/22.
//

import Foundation

extension Data {
    var prettyJson: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let jsonAsString = String(data: data, encoding:.utf8) else { return nil }

        return jsonAsString
    }
}
