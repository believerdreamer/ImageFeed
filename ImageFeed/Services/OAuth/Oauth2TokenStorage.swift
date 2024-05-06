import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private enum Keys: String {
        case token
    }
    
    var token: String? { //MARK: Token Storage
        get {
            KeychainWrapper.standard.string(forKey: Keys.token.rawValue)
        }
        set {
            let isSuccess = KeychainWrapper.standard.set(newValue ?? " ", forKey: Keys.token.rawValue)
            guard isSuccess else {
                assertionFailure("Ошибка записи токена")
                return
            }
        }
    }
}


