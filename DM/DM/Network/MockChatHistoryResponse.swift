//
//  MockChatHistoryResponse.swift
//  DM
//
//  Created by wenyu zhao on 2020/2/3.
//  Copyright © 2020 Ryan zhao. All rights reserved.
//

class MockChatHistoryResponse {
    static let shared = MockChatHistoryResponse()
    
    var chatHistoryDB = [String: [Message]]()
    
    func handlePostRequest(_ name: String, _ message: String) -> Bool {
        guard chatHistoryDB[name] != nil else {
            return false
        }
        
        chatHistoryDB[name]?.append(Message(text: message, isIncoming: false))
        chatHistoryDB[name]?.append(Message(text: "\(message)  \(message)", isIncoming: true))
        return true
    }
    
    func handleGetRequest(_ name: String) -> [Message]? {
        guard let thisChatHistory = chatHistoryDB[name] else {
            return nil
        }
        
        return thisChatHistory
    }
}
