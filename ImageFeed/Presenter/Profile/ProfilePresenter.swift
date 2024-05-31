import Kingfisher
import UIKit

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    var profile: Profile? { get }
    var avatarURL: String? { get }
    
    func clearCache()
    func viewDidLoad()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    init(view: ProfileViewControllerProtocol) {
        self.view = view
    }
    
    var profileImageService = ProfileImageService.shared
    var profileService = ProfileService.shared
    
    var avatarURL: String? {
        profileImageService.avatarURL
    }
    
    var profile: Profile? {
        profileService.profileData
    }
    
    func viewDidLoad() {
        clearCache()
        guard let profileData = profileService.profileData else {return}
        guard let profileImageURL = profileImageService.avatarURL else { return }
        view?.updateAvatar(url: profileImageURL)
        view?.updateProfileData(data: profileData)
    }
    
    func clearCache() {
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
    }
}
