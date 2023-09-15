import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage!

    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBAction func clickBackButton(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func tapShareButton(_ sender: Any) {
        let share = UIActivityViewController(
            activityItems: [image ?? UIImage()],
            applicationActivities: nil)
        
        present(share, animated: true)
    }
    
    @IBOutlet var imageView: UIImageView! {
        
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        }
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
        
        
        
        scrollView.minimumZoomScale = 0.25
        scrollView.maximumZoomScale = 1.25
        
        rescaleAndCenterImageInScrollView(image: image)
        
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
