import UIKit
import Kingfisher
import SwiftKeychainWrapper

//MARK:  - UIViewController

final class ProfileViewContoller: UIViewController{
    
    deinit {
        removeObserver()
    }
    
    //MARK: - Properties
    private let userDefaults = UserDefaults.standard
    private let tokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private let logoutService = ProfileLogoutService.shared
    
    @objc private func didTapButton() {
        showByeAlertAndLogout()
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: "YPBlack")
        super.viewDidLoad()
        clearCache()
        updateAvatar()
        configureExitButton()
        guard let profileData = profileService.profileData else {
            assertionFailure("profile data in ProfileViewController is nil")
            return
        }
        configureUIWithProfileData(data: profileData)
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    //MARK: - Private Functions
    private func showByeAlertAndLogout() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { [weak self] _ in
            self?.logoutService.logout()
            self?.switchToInitialViewController()
            
        }))

        alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }))

        present(alert, animated: true)
    }

    private func updateAvatar(){
        
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        let image = UIImageView()
        image.layer.masksToBounds = true
        let processor = RoundCornerImageProcessor(cornerRadius: 60)
        image.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder.jpeg"),
            options: [.processor(processor)])
        configureProfileImage(imageView: image)
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: ProfileImageService.didChangeNotification,
            object: nil)
    }
    
    private func clearCache() {
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
    }
    
    private func configureProfileImage(imageView: UIImageView) {
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.layer.cornerRadius = 20
    }
    
    private func configureExitButton() {
        let button = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(self.didTapButton))
        
        button.tintColor = UIColor(named: "YPRed")
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45).isActive = true
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
    }
    
    private func configureNameLabel(with text: Profile) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.text = profileService.profileData?.name
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.textColor = .white
        label.widthAnchor.constraint(equalToConstant: 241).isActive = true
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 110).isActive = true
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
    }
    
    private func configureNickname(with text: Profile) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.text = "@" + (profileService.profileData?.username ?? "default")
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(named: "YPGrey")
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 144).isActive = true
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
    }
    
    private func configureDescription(with text: Profile) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        label.text = profileService.profileData?.bio
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 170).isActive = true
    }
    
    private func configureUIWithProfileData(data: Profile) {
        configureNickname(with: data)
        configureDescription(with: data)
        configureNameLabel(with: data)
    }
    
    private func switchToInitialViewController() {
            guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
            let splash = SplashViewController()
            splash.modalPresentationStyle = .fullScreen
            window.rootViewController = splash
        }
    
}
