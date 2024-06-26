import UIKit
import ProgressHUD
import SwiftKeychainWrapper

final class SplashViewController: UIViewController {
    
    //MARK: - Properties
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthFlow"
    private let oauth2Service = OAuth2Service()
    private let storage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = storage.token, !token.isEmpty {
            switchToTabBarController()
            guard let token = storage.token else {
                assertionFailure("failed to get token from storage")
                return
            }
            fetchProfile(token)
        } else {
            presentAuthViewController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    //MARK: - Functions
    private func setupUI() {
        view.backgroundColor = UIColor(named: "YPBlack")
        let logo = UIImageView(image: UIImage(named: "splash_screen_logo"))
        logo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logo)
        
        NSLayoutConstraint.activate([
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController
        authVC?.delegate = self
        authVC?.modalPresentationStyle = .fullScreen
        present(authVC!, animated: true)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingPorgressHUD.show()
        profileService.fetchProfile(token: token) { result in
            UIBlockingPorgressHUD.dismiss()
            switch result {
            case .success(let profile):
                ProfileService.shared.profileData = profile
                self.profileImageService.fetchProfileImageURL(token: self.storage.token ?? "default token") { _ in }
            case .failure(let error):
                if let urlResponse = error as? HTTPURLResponse, urlResponse.statusCode == 403 {
                    self.showLimitExceededAlert()
                } else {
                    print("Error fetching profile: \(error)")
                    assertionFailure("failed to fetch profile")
                }
            }
        }
    }

    
    private func showLimitExceededAlert() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Превышен лимит запросов к Unsplash API",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
            guard let token = self?.storage.token else { return }
            self?.fetchProfile(token)
        }))
        present(alert, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            UIBlockingPorgressHUD.show()
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        storage.removeAll()
        oauth2Service.fetchAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            UIBlockingPorgressHUD.dismiss()
            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure:
                assertionFailure("Failed to fetch OAuth token!")
            }
        }
    }
}
