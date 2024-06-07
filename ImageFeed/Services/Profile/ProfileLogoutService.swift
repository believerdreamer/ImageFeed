import UIKit
import WebKit


final class ProfileLogoutService {
    
    // MARK: - Publuc Properties
    
    var profileSevice = ProfileService.shared
    var profileImageService = ProfileImageService.shared
    var imageListService = ImageListService.shared
    
    // MARK: - Public Constants
    
    static let shared = ProfileLogoutService()
    
    // MARK: - Private Properties
    
    private var storage = OAuth2TokenStorage()
    
    private init() { }
    
    // MARK: - Public Methods
    
    func logout() {
        storage.removeToken()
        cleanCookies()
        imageListService.photos.removeAll()
        profileImageService.avatarURL = "" 
        profileSevice.profileData = nil
    }
    
    // MARK: - Private Methods

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    

    

}
