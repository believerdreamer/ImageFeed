import UIKit
import Kingfisher
import SwiftKeychainWrapper

//MARK:  - UIViewController

protocol ProfileViewControllerProtocol: AnyObject {
    func updateAvatar()
    func updateProfileData(data: Profile)
}

final class ProfileViewContoller: UIViewController, ProfileViewControllerProtocol{
    
    
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
        addSubViews()
        applyConstraints()
        guard let profileData = profileService.profileData else {
            return
        }
        updateProfileData(data: profileData)
        guard let profileData = profileService.profileData else {
            assertionFailure("profile data in ProfileViewController is nil")
            return
        }
        
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
        alert.addAction(UIAlertAction(
            title: "Да",
            style: .default,
            handler: { [weak self] _ in
                self?.logoutService.logout()
                self?.switchToInitialViewController()
                
            }))
        
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }))
        
        present(alert, animated: true)
    }
    
    internal func updateAvatar(){
        profileImage.kf.indicatorType = .activity
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL) else { return }
        profileImage.kf.setImage(with: url, placeholder: UIImage(named: "avatar_placeholder"))
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
    }
    
    private func clearCache() {
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
    }
    
    private func addSubViews(){
        view.addSubview(profileImage)
        view.addSubview(nameLabel)
        view.addSubview(nickname)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
    }
    
    private func applyConstraints(){
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nickname.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            nickname.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            nickname.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: nickname.bottomAnchor, constant: 8),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor)
        ])
    }
    
    private var profileImage: UIImageView = {
        let profileImage = UIImageView(image: UIImage(named: "Avatar"))
        profileImage.layer.cornerRadius = 35
        profileImage.clipsToBounds = true
        return profileImage
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private var nickname: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(named: "YPGrey")
        return label
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        return label
    }()
    
    private var logoutButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward")!,
            target: ProfileViewContoller.self,
            action: #selector(didTapButton))
        button.tintColor = UIColor(named: "YPRed")
        return button
    }()
    
    internal func updateProfileData(data: Profile) {
        guard let profile = profileService.profileData else {
            assertionFailure("Profile is doesnt exist")
            return
        }
        self.nameLabel.text = profile.name
        self.nickname.text = "@" + profile.username
        self.descriptionLabel.text = profile.bio
    }
    
    private func switchToInitialViewController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let splash = SplashViewController()
        splash.modalPresentationStyle = .fullScreen
        window.rootViewController = splash
    }
    
}
