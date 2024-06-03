import Foundation
import Kingfisher

final class ProfileService {
    
    private init(){}
    
    // MARK: - Public Constants
    
    static let shared = ProfileService()
    
    // MARK: - Private Constants
    
    private let urlSession = URLSession.shared
    
    private enum ProfileServiceError: Error {
        case invalidRequest
    }
    
    // MARK: - Public Properties
    
    var profileData: Profile?
    
    // MARK: - Private Properties
    
    private var task: URLSessionTask?
    
    //MARK: Functions
    func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = Constants.profileURL else {return nil}
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
                        name: "\(profileResult.firstName) \(profileResult.lastName ?? "")",
                        loginName: profileResult.username,
                        bio: profileResult.bio ?? ""
                    )
                    completion(.success(profile))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            self.task = nil
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
                print("[fetchProfileTask]: \(error)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let errorDescription = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                print(errorDescription)
                let error = NetworkError.httpStatusCode(statusCode)
                print("[fetchProfileTask]: \(error)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let error = NetworkError.urlSessionError
                print("[fetchProfileTask]: \(error)")
                completion(.failure(error))
                return
            }

            do {
                let profileResult = try decoder.decode(ProfileResult.self, from: data)
                completion(.success(profileResult))
            } catch {
                print("[fetchProfileTask]: \(error)")
                completion(.failure(error))
            }
        }
    }

}
