//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Архип Семёнов on 23.05.2024.
//

import Foundation

struct ProfileResult: Codable {
    let username: String
    let first_name: String
    let last_name: String
    let bio: String?
}

struct Profile {
    var username: String
    var name: String
    var loginName: String
    var bio: String
    
    init(username: String, name: String, loginName: String, bio: String) {
        self.username = username
        self.name = name
        self.loginName = loginName
        self.bio = bio
    }
}

