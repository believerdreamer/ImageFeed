import UIKit
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    var profileSevice = ProfileService.shared
    var profileImageService = ProfileImageService.shared
    var imageListService = ImageListService.shared
    private var storage = OAuth2TokenStorage()
    
    private init() { }
    
    func logout() {
        storage.removeToken()
        cleanCookies()
        imageListService.photos.removeAll()
        profileImageService.avatarURL = " "
        profileSevice.profileData = nil
        switchToInitialViewController()
        
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func switchToInitialViewController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "AuthViewController")
        tabBarController.modalPresentationStyle = .fullScreen
        window.rootViewController = tabBarController
    }
    

}
