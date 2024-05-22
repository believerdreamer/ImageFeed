import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet private var tableView: UITableView!
    private let ShowSingleImageViewIdentifier = "ShowSingleImage"
    private var isLoadingNextPage = false
    var photos: [ImageListService.Photo] = []
    private var imageListService = ImageListService.shared
    @IBAction func likeButtonAction(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? ImagesListCell,
              let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        var photo = imageListService.photos[indexPath.row]
        let shouldLike = !photo.isLiked
        
        imageListService.changeLike(photoId: photo.id, isLike: shouldLike) { [weak self] result in
            switch result {
            case .success:
                photo.isLiked = shouldLike
                self?.imageListService.photos[indexPath.row] = photo
                DispatchQueue.main.async {
                    cell.likeButton.setImage(shouldLike ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off"), for: .normal)
                }
            case .failure(let error):
                print("Failed to change like status: \(error)")
            }
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearCache()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        imageListService.fetchPhotosNextPage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableViewAnimated), name: ImageListService.didChangeNotification, object: nil)
    }
    
    // MARK: - Functions
    private func clearCache() {
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
    }
    
    @objc func updateTableViewAnimated() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageViewIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController,
                  let indexPath = sender as? IndexPath else {
                return
            }
            let photo = imageListService.photos[indexPath.row]
            viewController.fullImageURL = URL(string: photo.fullImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    @objc private func likeButtonTapped(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? ImagesListCell,
              let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        var photo = imageListService.photos[indexPath.row]
        let shouldLike = !photo.isLiked
        
        imageListService.changeLike(photoId: photo.id, isLike: shouldLike) { [weak self] result in
            switch result {
            case .success:
                photo.isLiked = shouldLike
                self?.imageListService.photos[indexPath.row] = photo
                DispatchQueue.main.async {
                    cell.likeButton.setImage(shouldLike ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off"), for: .normal)
                }
            case .failure(let error):
                print("Failed to change like status: \(error)")
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageListService.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIndetifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        let photo = imageListService.photos[indexPath.row]
        imageListCell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        imageListCell.likeButton.setImage(photo.isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off"), for: .normal)
        imageListCell.likeButton.addTarget(self, action: #selector(likeButtonTapped(_:)), for: .touchUpInside)
        
        if let url = URL(string: photo.regularImageURL) {
            imageListCell.cellImage.kf.setImage(with: url, placeholder: UIImage(named: "placeholder_image"), options: [.transition(.fade(0.2))])
        }
        
        return imageListCell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageViewIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 370 : 252
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == imageListService.photos.count - 1 {
            imageListService.fetchPhotosNextPage()
        }
    }

    
}

