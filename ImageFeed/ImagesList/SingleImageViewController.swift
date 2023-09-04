import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage!
    
    @IBOutlet var imageView: UIImageView! {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
} 
