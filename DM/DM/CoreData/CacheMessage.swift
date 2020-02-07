//
//  CacheMessage.swift
//  DM
//
//  Created by wenyu zhao on 2020/2/5.
//  Copyright © 2020 Ryan zhao. All rights reserved.
//

import Foundation

public class CacheMessage: NSObject, NSCoding {
    // MARK: - Property
    public var text: String
    public var isIncoming: Bool
    
    public enum Key: String {
        case text = "text"
        case isIncoming = "isIncoming"
    }
    
    // MARK: - Initialize
    init(text: String, isIncoming: Bool) {
        self.text = text
        self.isIncoming = isIncoming
    }
    
    // MARK: - NSCoding
    public required convenience init?(coder: NSCoder) {
        let decodedText = coder.decodeObject(forKey: Key.text.rawValue) as? String ?? ""
        let decodedIsIncoming = coder.decodeBool(forKey: Key.isIncoming.rawValue)
        
        self.init(text: decodedText, isIncoming: decodedIsIncoming)
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(text, forKey: Key.text.rawValue)
        coder.encode(isIncoming, forKey: Key.isIncoming.rawValue)
    }
}
