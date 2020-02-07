//
//  Constants.swift
//  DM
//
//  Created by wenyu zhao on 2020/2/1.
//  Copyright © 2020 Ryan zhao. All rights reserved.
//

class Constants {
    // MARK: - Networking, error messages and other localied string
    static let baseUrl = "https://api.github.com/"
    static let navigationTitle = "GitHub DM"
    static let failedTitle = "Error"
    static let failedMessage = "Something is wrong, please try again later."
    static let rateLimitMessage = "You are requesting too often, please try an hour later or visit https://developer.github.com/v3/#rate-limiting for detail"
    static let confirm = "OK"
    static let rateLimitKey = "X-RateLimit-Remaining"
    
    // MARK: - TableViewCell Identifier
    static let teamlistCellIdentifier = "teammateCell"
    static let messageCellIdentifier = "MessageCell"
    
    // MARK: - Asserts names
    static let placeholderAvatarImage = "avatar_placeholder"
    
    // MARK: - CoreData related
    static let coreDataEntityName = "ChatHistory"
}
