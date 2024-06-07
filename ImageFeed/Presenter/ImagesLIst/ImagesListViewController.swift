import UIKit
import Kingfisher

// MARK: - UIViewController

protocol ImagesListViewControllerProtocol: AnyObject {
    func likeButtonTapped(_ sender: UIButton)
    func clearCache()
    var tableView: UITableView! { get set }
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    // MARK: - Public Properties
    var photos: [Photo] = []
    
    // MARK: - Private constants
    private let ShowSingleImageViewIdentifier = "ShowSingleImage"
    private var isLoadingNextPage = false
    private var imageListService = ImageListService.shared
    lazy var presenter = ImagesListPresenter(view: self)
    
    private lazy var dateFormatter: DateFormatter = {
        presenter.formatDate()
    }()
    
    // MARK: - IBOutlet
    @IBOutlet internal var tableView: UITableView!
    
    // MARK: - IBAction
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        presenter.likeButtonTapped(sender)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        clearCache()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        imageListService.fetchPhotosNextPage { result in
            switch result {
            case .success:
                print("Successfully fetched next page of photos.")
            case .failure(let error):
                print("Failed to fetch next page of photos: \(error)")
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableViewAnimated), name: ImageListService.didChangeNotification, object: nil)
    }
    
    // MARK: - Private Functions
    internal func clearCache() {
        presenter.clearCache()
    }
    
    // MARK: - Public Functions
    @objc func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        photos = imageListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
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
        
        var photo = imageListService.photos[indexPath.row]
        imageListCell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        imageListCell.likeButton.setImage(photo.isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off"), for: .normal)
        imageListCell.likeButton.addTarget(self, action: #selector(likeButtonTapped(_:)), for: .touchUpInside)
        
        if let url = URL(string: photo.smallImageURL) {
            imageListCell.cellImage.kf.setImage(with: url, placeholder: UIImage(named: "placeholder_feed"), options: [.transition(.fade(0.2))]) { result in
                switch result {
                case .success(let value):
                    let imageSize = value.image.size
                    photo.size = imageSize
                    self.imageListService.photos[indexPath.row] = photo
                    tableView.beginUpdates()
                    tableView.endUpdates()
                case .failure(let error):
                    print("Failed to load image: \(error)")
                }
            }
        }
        
        return imageListCell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageViewIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == imageListService.photos.count - 1 {
            imageListService.fetchPhotosNextPage { _ in }
        }
    }
}
