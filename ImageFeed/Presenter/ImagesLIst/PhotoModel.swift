//
//  PhotoModel.swift
//  ImageFeed
//
//  Created by Архип Семёнов on 23.05.2024.
//
import Foundation

struct Photo {
    let id: String
    var size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let fullImageURL: String
    let regularImageURL: String
    let smallImageURL: String
    var isLiked: Bool
}
