import Foundation

final class OAuth2TokenStorage {
    private enum Keys: String {
        case token
    }
    
    var token: String? { //MARK: Token Storage
        get {
            UserDefaults.standard.string(forKey: Keys.token.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.token.rawValue)
        }
    }
}


