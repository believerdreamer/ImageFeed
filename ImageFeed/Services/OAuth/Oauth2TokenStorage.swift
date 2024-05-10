import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private enum Keys: String {
        case token
    }
    
    var token: String? { //MARK: Token Storage
        get {
            print("getting token with keychain - \(String(describing: KeychainWrapper.standard.string(forKey: Keys.token.rawValue)))")
            
            return KeychainWrapper.standard.string(forKey: Keys.token.rawValue)

//
        }
        set {
            print("setting new token with keychain - \(String(describing: newValue))")
            KeychainWrapper.standard.set(newValue ?? "default token value", forKey: Keys.token.rawValue)

        }
    }
}

