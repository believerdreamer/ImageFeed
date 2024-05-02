import Foundation

private enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
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
            assert(Thread.isMainThread)
            guard lastCode != code else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
            
            task?.cancel()
            lastCode = code
            
            guard
                let request = authTokenRequest(code: code)
            else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
            
            let task = fetchTokenTask(request: request) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let body):
                        let authToken = body.accessToken
                        self.authToken = authToken
                        completion(.success(authToken))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                    self.lastCode = nil
                    self.task = nil
                }
            }
            self.task = task
            task.resume()
        }
    
    private func fetchTokenTask(
         request: URLRequest,
         completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
     ) -> URLSessionTask {
         let decoder = JSONDecoder()
         return urlSession.data(for: request) {(result: Result<Data, Error>) in
             let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                 Result { try decoder.decode(OAuthTokenResponseBody.self, from: data) }
             }
             switch response {
             case .success(let body):
                 completion(.success(body))
             case .failure(let error):
                 print("[fetchTokenTask]: \(error)")
                 completion(.failure(error))
             }
         }
     }

    
    private func authTokenRequest(code: String) -> URLRequest? {
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

