import UIKit

//MARK:  - UIViewController

final class ProfileViewContoller: UIViewController{
    
    struct Profile {
        var username: String
        var name: String
        var loginName: String
        var bio: String
    }
    
    //MARK: - Properties
    private let userDefaults = UserDefaults.standard
    private let tokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    
    @objc private func didTapButton() {
        performSegue(withIdentifier: "ShowAuthScreen", sender: nil)
        userDefaults.removeObject(forKey: tokenStorage.token!)
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureProfileImage()
        configureExitButton()
        DispatchQueue.main.async {
            self.configureUIWithProfileData(data: self.profileService.profileData!)
        }
    }
    
    //MARK: - Configure screen objects
    private func configureProfileImage() {
        
        let profileImage = UIImage(named: "UserPhoto")
        let imageView = UIImageView(image: profileImage)
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
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
    
    private func configureNameLabel(with text: ProfileService.Profile) {
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
    
    private func configureNickname(with text: ProfileService.Profile) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.text = "@" + (profileService.profileData?.username ?? "default")
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(named: "YPGrey")
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 144).isActive = true
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
    }
    
    private func configureDescription(with text: ProfileService.Profile) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        label.text = profileService.profileData?.bio
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 170).isActive = true
    }
    
    private func configureUIWithProfileData(data: ProfileService.Profile) {
        configureNickname(with: data)
        configureDescription(with: data)
        configureNameLabel(with: data)
    }
    
}