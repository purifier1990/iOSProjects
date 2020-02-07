//
//  CacheChatHistory.swift
//  DM
//
//  Created by wenyu zhao on 2020/2/4.
//  Copyright © 2020 Ryan zhao. All rights reserved.
//

import Foundation

public class CacheChatHistory: NSObject, NSCoding {
    // MARK: - Property
    public var history: [String: [CacheMessage]] = [:]
    
    public enum Key: String {
        case history = "history"
    }
    
    // MARK: - Initilize
    init(history: [String: [CacheMessage]]) {
        self.history = history
    }
    
    // MARK: - NSCoding
    public func encode(with coder: NSCoder) {
        coder.encode(history, forKey: Key.history.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        let decodedHistory = coder.decodeObject(forKey: Key.history.rawValue) as! [String: [CacheMessage]]
        
        self.init(history: decodedHistory)
    }
}
