//
//  Message.swift
//  DM
//
//  Created by wenyu zhao on 2020/2/3.
//  Copyright © 2020 Ryan zhao. All rights reserved.
//

enum SendMessageStatus {
    case success
    case idle
}

struct Message: Codable {
    var text: String
    var isIncoming: Bool
}

extension Message: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.isIncoming == rhs.isIncoming && lhs.text == rhs.text
    }
}
