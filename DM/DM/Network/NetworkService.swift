//
//  URLSessioManager.swift
//  DM
//
//  Created by wenyu zhao on 2020/2/1.
//  Copyright © 2020 Ryan zhao. All rights reserved.
//

import Foundation

public enum ServiceError: Error {
    case invalidData
    case unknownResponse
    case requestError
    case rateLimitReached
}

public protocol Service {
    func get(urlString: String, completion: @escaping (Result<Data, ServiceError>) -> Void)
}

public final class NetworkService: Service {
    public func get(urlString: String, completion: @escaping (Result<Data, ServiceError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.requestError))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                completion(.failure(.unknownResponse))
                return
            }

            if let response = response as? HTTPURLResponse {
                let statusCode = response.statusCode
                
                // Handle limit rate specific error
                if statusCode == 403 {
                    if let num =  response.allHeaderFields[Constants.rateLimitKey] as? String, num == "0" {
                        completion(.failure(.rateLimitReached))
                        return
                    }
                }
                
                //300 Redirection messages
                //400 Client error responses
                //500 Server error responses
                //Treat as general error
                if statusCode >= 300 {
                    completion(.failure(.requestError))
                    return
                }
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            completion(.success(data))
            }.resume()
    }
}

