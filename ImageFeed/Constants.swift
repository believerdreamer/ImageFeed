//
//  Constants.swift
//  ImageFeed
//
//  Created by Архип Семёнов on 03.06.2024.
//

import Foundation

enum Constants {
    static let accessKey: String = "K6ujim4CuKUuEB6MNLIj49av69n-h6UJjHHc9ZDBnSU"
    static let secretKey: String = "UNIaYqYPhBpC07JsR4Z903hWAT2VCZkpFU42ztfM2oY"
    static let redirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
    static let defaultBaseURL: URL = URL(string: "https://api.unsplash.com")!
    static let accessScope: String = "public+read_user+write_likes"
    static let profileURL = URL(string: "https://api.unsplash.com/me")
    static let photoURL = "https://api.unsplash.com/photos/"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}
