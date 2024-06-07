//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Архип Семёнов on 23.05.2024.
//

import Foundation

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?

    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    var username: String
    var name: String
    var bio: String
    
    init(username: String, name: String, loginName: String, bio: String) {
        self.username = username
        self.name = name
        self.bio = bio
    }
}

