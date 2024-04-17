import Foundation

final class ProfileService {
    
    //MARK: Properties
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private enum ProfileServiceError: Error {
        case invalidRequest
    }
    
    struct ProfileResult: Codable {
        let username: String
        let first_name: String
        let last_name: String
        let bio: String?
    }
    
    struct Profile {
        var username: String
        var name: String
        var loginName: String
        var bio: String
        
        init(username: String, name: String, loginName: String, bio: String) {
            self.username = username
            self.name = name
            self.loginName = loginName
            self.bio = bio
        }
    }
    
    //MARK: Functions
    
    func makeProfileRequest(token: String) -> URLRequest? {
        let url = URL(string: "https://api.unsplash.com/me")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(
        token: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        let task = fetchProfileTask(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profileResult):
                    let profile = Profile(
                        username: profileResult.username,
                        name: "\(profileResult.first_name) \(profileResult.last_name)",
                        loginName: profileResult.username,
                        bio: profileResult.bio ?? ""
                    )
                    completion(.success(profile))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    private func fetchProfileTask(
        request: URLRequest,
        completion: @escaping (Result<ProfileResult, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let errorDescription = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                completion(.failure(ProfileServiceError.invalidRequest))
                return
            }
            
            guard let data = data else {
                completion(.failure(ProfileServiceError.invalidRequest))
                return
            }
            
            do {
                let profileResult = try decoder.decode(ProfileResult.self, from: data)
                completion(.success(profileResult))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
