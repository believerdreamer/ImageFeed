import UIKit

final class AuthViewController: UIViewController {
    let ShowWebViewSegueIdentifier: String = "ShowWebView"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewSegueIdentifier {
            guard 
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(ShowWebViewSegueIdentifier)")}
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDegelate {
    func webViewViewController(_vc: WebViewViewController, didAuthenticateWithCode code: String) {
        //TODO: Process code
    }
    
    func webViewViewControllerDidCancel(_vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
