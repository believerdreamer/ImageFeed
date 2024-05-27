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

struct AuthConfiguration {
    
    static var standart: AuthConfiguration {
        return AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            authURLString: Constants.unsplashAuthorizeURLString,
            defaultBaseURL: Constants.defaultBaseURL
            
        )
    }
    
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let defaultBaseURL: URL
    let accessScope: String
    let authURLString: String

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
}




