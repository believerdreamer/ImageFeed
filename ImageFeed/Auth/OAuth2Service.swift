import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    private (set) var authToken: String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }
    
    func fetchAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
    let request = authTokenRequest(code: code)
        let task = fetchTokenTask(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                completion(.success(authToken))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func fetchTokenTask(
        request: URLRequest,
        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
                    let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                        Result { try decoder.decode(OAuthTokenResponseBody.self, from: data) }
                    }
                    completion(response)
                }
            }
    
    private func authTokenRequest(code: String) -> URLRequest {
        let urlString = "https://unsplash.com/oauth/token"
        let parameters: [String: String] = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        return URLRequest.makeHTTPRequest(
            urlString: urlString,
            parameters: parameters,
            httpMethod: "POST")
    }
}

