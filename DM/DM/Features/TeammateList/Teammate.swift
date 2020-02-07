//
//  Teammate.swift
//  DM
//
//  Created by wenyu zhao on 2020/2/1.
//  Copyright © 2020 Ryan zhao. All rights reserved.
//

enum FailType {
    case rateLimit
    case general
}

struct Teammate: Codable {
    var id: Int
    var nodeId: String
    var gravatarId: String
    var url: String
    var htmlUrl: String
    var followersUrl: String
    var followingUrl: String
    var gistsUrl: String
    var starredUrl: String
    var subscriptionsUrl: String
    var organizationsUrl: String
    var reposUrl: String
    var eventsUrl: String
    var receivedEventsUrl: String
    var type: String
    var siteAdmin: Bool
    var avatarUrl: String
    var login: String
}
