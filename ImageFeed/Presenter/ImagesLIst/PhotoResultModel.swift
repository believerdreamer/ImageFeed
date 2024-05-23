//
//  PhotoResultModel.swift
//  ImageFeed
//
//  Created by Архип Семёнов on 23.05.2024.
//

import Foundation

struct UrlResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let welcomeDescription: String?
    let urls: UrlResult
    let size: CGSize

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case welcomeDescription = "description"
        case urls
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        createdAt = try? container.decode(String.self, forKey: .createdAt)
        welcomeDescription = try? container.decode(String.self, forKey: .welcomeDescription)
        urls = try container.decode(UrlResult.self, forKey: .urls)
        size = .zero
    }
}

