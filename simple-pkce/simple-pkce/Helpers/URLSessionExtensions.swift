//
//  URLSessionExtensions.swift
//  simple-pkce
//
//  Created by Billy Bray on 4/6/22.
//

import Foundation

extension URLSession {
    func dataTask(with url: URL, handler: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask {
        dataTask(with: url) { data, _, error in
            if let error = error {
                handler(.failure(error))
            } else {
                handler(.success(data ?? Data()))
            }
        }
    }
}
