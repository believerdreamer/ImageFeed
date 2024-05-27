import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private enum Keys: String {
        case token
    }
    
     var token: String? { //MARK: Token Storage
        get {
            print("Getting token with keychain - \(String(describing: KeychainWrapper.standard.string(forKey: Keys.token.rawValue)))")
            return KeychainWrapper.standard.string(forKey: Keys.token.rawValue)
        }
        set {
            print("Setting new token with keychain - \(String(describing: newValue))")
            KeychainWrapper.standard.set(newValue ?? "", forKey: Keys.token.rawValue)

        }
    }
    
    func removeToken() {
        print("Removing token from keychain")
        KeychainWrapper.standard.removeObject(forKey: Keys.token.rawValue)
    }
    
    func removeAll() {
        KeychainWrapper.standard.removeAllKeys()
    }
}

