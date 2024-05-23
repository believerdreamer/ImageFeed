import UIKit
import Kingfisher
import SwiftKeychainWrapper

// MARK: - UIViewController

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Constants
    private let userDefaults = UserDefaults.standard
    private let tokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let logoutService = ProfileLogoutService.shared
    
    // MARK: - Private properties
    private var profileImageServiceObserver: NSObjectProtocol?
    private var profileImageView: UIImageView!
    private var avatarGradient: CAGradientLayer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YPBlack")
        
        setupProfileImageView()
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
    
    deinit {
        removeObserver()
    }
    
    // MARK: - Private Methods
    
    private func setupProfileImageView() {
        profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.masksToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        
        NSLayoutConstraint.activate([
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
        
        profileImageView.layer.cornerRadius = 35
        addAvatarGradient()
    }
    
    private func addAvatarGradient() {
        if let existingGradient = avatarGradient {
            existingGradient.removeFromSuperlayer()
        }
        
        let avatarGradientColors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        
        let gradient = CAGradientLayer()
        gradient.frame = profileImageView.bounds
        gradient.colors = avatarGradientColors
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 35
        
        profileImageView.layer.insertSublayer(gradient, at: 0)
        addGradientAnimation(to: gradient, fromValue: [0, 0.1, 0.3], toValue: [0, 0.8, 1], duration: 1.0)
        
        avatarGradient = gradient
    }
    
    private func switchToInitialViewController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let splash = SplashViewController()
        splash.modalPresentationStyle = .fullScreen
        window.rootViewController = splash
    }
    
    @objc private func didTapButton() {
        showByeAlertAndLogout()
    }
    
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
    
    private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL) else {
            return
        }
        
        // Используем Kingfisher для загрузки изображения
        let processor = RoundCornerImageProcessor(cornerRadius: 60)
        profileImageView.kf.setImage(
            with: url,
            placeholder: nil, // Убираем заглушку, так как мы показываем градиент
            options: [.processor(processor)]) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    // Изображение успешно загружено, удаляем градиентный слой
                    self.avatarGradient?.removeFromSuperlayer()
                case .failure(_):
                    // Произошла ошибка загрузки изображения
                    print("Failed to load profile image.")
                }
        }
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
}

extension ProfileViewController {
    func addGradientAnimation(to gradient: CAGradientLayer, fromValue: [NSNumber], toValue: [NSNumber], duration: CFTimeInterval) {
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = duration
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = fromValue
        gradientChangeAnimation.toValue = toValue
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Обновляем градиентный слой при изменении размеров родительского представления
        avatarGradient?.frame = profileImageView.bounds
    }
    
    
}
