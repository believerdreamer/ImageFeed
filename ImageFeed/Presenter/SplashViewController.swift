import UIKit
import ProgressHUD
import SwiftKeychainWrapper

final class SplashViewController: UIViewController { //MARK: UIViewController
    
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
        
        if storage.token != nil {
            switchToTabBarController()
            fetchProfile(storage.token ?? " ")
            
        } else {
            //            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
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
        profileService.fetchProfile(token: token) {result in
            print("token for profile is \(token). type of token - \(type(of: token))")
            switch result {
            case .success(let body):
                print(body)
                ProfileService.shared.profileData = body
                self.profileImageService.fetchProfileImageURL(token: self.storage.token ?? "default token") {_ in }
            case .failure(let error):
                print(error)
                assertionFailure("failed to fetch profile")
                break
            }
            UIBlockingPorgressHUD.dismiss()
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate { //MARK: AuthViewControllerDelegate
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            UIBlockingPorgressHUD.show()
            guard let self = self else { return }
            self.fetchOAuthToken(code)
            UIBlockingPorgressHUD.dismiss()
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        storage.removeAll()
        oauth2Service.fetchAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure:
                assertionFailure("Failed to fetch OAuth token!")
                break
            }
        }
    }
}


