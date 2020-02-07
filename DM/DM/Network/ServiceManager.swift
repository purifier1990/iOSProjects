//
//  ServiceManager.swift
//  DM
//
//  Created by wenyu zhao on 2020/2/1.
//  Copyright © 2020 Ryan zhao. All rights reserved.
//
import Foundation

protocol API {
    func getTeammatesList(completion: @escaping (Result<[Teammate], ServiceError>) -> Void)
    func getAvatarImage(imagePath: String,
                        completion: @escaping (Result<Data, ServiceError>) -> Void)
    func mockPostMessage(_ name: String,
                         _ message: String,
                         completion: @escaping(Result<Void, ServiceError>) -> Void)
    func mockGetChatMessages(_ name: String,
                             completion: @escaping(Result<[Message], ServiceError>) -> Void) 
}

class ServiceManager: API {
    // MARK: - Property
    let service: NetworkService
    
    static let shard = ServiceManager()
    
    fileprivate init(service: NetworkService? = nil) {
        self.service = service ?? NetworkService()
    }
    
    // MARK: - RestAPI wrapper
    func getTeammatesList(completion: @escaping (Result<[Teammate], ServiceError>) -> Void) {
        
        service.get(urlString: Constants.baseUrl + "users") { (result: Result<Data, ServiceError>) in
            do {
                switch result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let teammatesList = try decoder.decode([Teammate].self, from: data)
                    completion(.success(teammatesList))
                case .failure(let error):
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(.invalidData))
            }
        }
    }
    
    func getAvatarImage(imagePath: String, completion: @escaping (Result<Data, ServiceError>) -> Void) {
        service.get(urlString: imagePath) { (result: Result<Data, ServiceError>) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Mock service wrapper
    func mockPostMessage(_ name: String,
                         _ message: String,
                         completion: @escaping(Result<Void, ServiceError>) -> Void) {
        if MockChatHistoryResponse.shared.handlePostRequest(name, message) {
            completion(.success(()))
        } else {
            completion(.failure(.requestError))
        }
    }
    
    func mockGetChatMessages(_ name: String, completion: @escaping(Result<[Message], ServiceError>) -> Void) {
        // Didn't mock a serviceError in this case
        
        guard let chatHistory =  MockChatHistoryResponse.shared.handleGetRequest(name) else {
            completion(.success([Message]()))
            return
        }
        
        completion(.success(chatHistory))
    }
}

