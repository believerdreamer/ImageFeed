import UIKit
import WebKit

fileprivate let UnsplashAuthorizeURLString: String = "https://unsplash.com/oauth/authorize"

protocol WebViewViewControllerDegelate: AnyObject {
    func webViewViewController(_vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_vc: WebViewViewController)
}

//UIViewController
final class WebViewViewController: UIViewController {
    
    weak var delegate: WebViewViewControllerDegelate?
    
    //@IBOutlets
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    //@IBActions
    @IBAction private func didTapBackButton(_ sender: Any) {
        delegate?.webViewViewControllerDidCancel(_vc: self)
    }
    //Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        var urlComponents = URLComponents(string: UnsplashAuthorizeURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: AccessScope)
        ]
        let url = urlComponents.url!
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: {$0.name == "code"})
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            //TODO: Process code
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
}


