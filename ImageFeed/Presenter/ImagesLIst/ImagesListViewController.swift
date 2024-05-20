import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet private var tableView: UITableView!
    
    private let ShowSingleImageViewIdentifier = "ShowSingleImage"
    private var imageListService = ImageListService()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        imageListService.fetchPhotosNextPage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableViewAnimated), name: ImageListService.didChangeNotification, object: nil)
    }
    
    // MARK: - Functions
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
            viewController.imageURL = URL(string: photo.largeImageURL)
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
        
        let photo = imageListService.photos[indexPath.row]
        imageListCell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        imageListCell.likeButton.setImage(photo.isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off"), for: .normal)
        
        if let url = URL(string: photo.thumbImageURL) {
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
        // Здесь можете использовать фиксированную высоту ячейки
        return 200
    }
}
