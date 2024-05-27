//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Архип Семёнов on 02.05.2024.
//

import Foundation

final class ProfileImageService {
    
    // MARK: - Public Constants
    
    static let shared = ProfileImageService(); private init(){}
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    // MARK: - Private Constants
    
    private let urlSession = URLSession.shared
    private enum ProfileImageServiceError: Error {
        case invalidRequest
    }
    
    // MARK: - Private Properties
    
    private var profileService = ProfileService.shared
    private var task: URLSessionTask?
    private var nickname: String?
    
    // MARK: - Public Properties
    
    var avatarURL: String?
    
    // MARK: - Public Methods
    
    func makeProfileImageRequest(token: String) -> URLRequest? {
        guard let nickname = profileService.profileData?.username else {return nil}
        let url = URL(string: "https://api.unsplash.com/users/\(nickname)")
        guard let url = url else {
            assertionFailure("failed to create profile url")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfileImageURL(
        token: String,
        completion: @escaping (Result<UserResult, Error>) -> Void
    ) {
        guard let request = makeProfileImageRequest(token: token) else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        let task = fetchProfileImageTask(request: request) { result in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let imageResult):
                    self.avatarURL = imageResult.profileImage.large.absoluteString
                    print(self.avatarURL ?? "No avatar URL available")
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": self.avatarURL ?? ""])
                    completion(.success(imageResult))

                case .failure(let error):
                    completion(.failure(error))
                }
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func fetchProfileImageTask(
          request: URLRequest,
          completion: @escaping (Result<UserResult, Error>) -> Void
      ) -> URLSessionTask {
          let decoder = JSONDecoder()
          return urlSession.dataTask(with: request) { (data, response, error) in
              if let error = error {
                  print("[fetchProfileImageTask]: \(error)")
                  completion(.failure(error))
                  return
              }

              guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                  let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                  let errorDescription = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                  print(errorDescription)
                  let error = NetworkError.httpStatusCode(statusCode)
                  print("[fetchProfileImageTask]: \(error)")
                  completion(.failure(error))
                  return
              }

              guard let data = data else {
                  let error = NetworkError.urlSessionError
                  print("[fetchProfileImageTask]: \(error)")
                  completion(.failure(error))
                  return
              }

              do {
                  let profileResult = try decoder.decode(UserResult.self, from: data)
                  completion(.success(profileResult))
              } catch {
                  print("[fetchProfileImageTask]: \(error)")
                  completion(.failure(error))
              }
          }
      }

}
