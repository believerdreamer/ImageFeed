import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage!
    
    @IBAction func clickBackButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
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
