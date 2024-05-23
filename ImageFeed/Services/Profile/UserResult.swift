//
//  UserResult.swift
//  ImageFeed
//
//  Created by Архип Семёнов on 23.05.2024.
//

import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage

    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
