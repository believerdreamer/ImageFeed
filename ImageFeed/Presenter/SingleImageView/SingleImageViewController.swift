import UIKit
import Kingfisher
import ProgressHUD

final class SingleImageViewController: UIViewController {
    
    // MARK: - Properties
    var imageURL: URL?
    var fullImageURL: URL?
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 0.25
        scrollView.maximumZoomScale = 1.25
        scrollView.delegate = self
        
        loadImage()
    }
    //MARK
    @IBAction private func tapShareButton(_ sender: Any) {
          let share = UIActivityViewController(
              activityItems: [imageView ?? UIImage()],
              applicationActivities: nil)
          
          present(share, animated: true)
      }
    
    // MARK: - Private Methods
    
    private func loadImage() {
        guard let url = fullImageURL else {
            print("fullImageURL is nil")
            return
        }
        
        showLoader()
        imageView.kf.setImage(with: url, completionHandler: { [weak self] result in
            self?.hideLoader()
            switch result {
            case .success(let value):
                self?.rescaleAndCenterImageInScrollView(image: value.image)
            case .failure(let error):
                print("Error loading image: \(error)")
                self?.showError()
            }
        })
    }
    
    private func showLoader() {
        UIBlockingPorgressHUD.show()
    }
    
    private func hideLoader() {
        UIBlockingPorgressHUD.dismiss()
    }
    
    private func showError() {
        let alert = UIAlertController(
            title: "Error",
            message: "Что-то пошло не так. Попробовать ещё раз?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
            self?.loadImage()
        }))
        present(alert, animated: true)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    // MARK: - Actions
    
    @IBAction private func clickBackButton(_ sender: Any) {
        dismiss(animated: true)
        UIBlockingPorgressHUD.dismiss()
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
