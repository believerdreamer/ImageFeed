//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Архип Семёнов on 02.05.2024.
//

import Foundation

final class ProfileImageService {
    
    static var shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private var profileService = ProfileService.shared
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private (set) var avatarURL: String?
    private var nickname: String?
    private enum ProfileImageServiceError: Error {
        case invalidRequest
    }
    
    struct UserResult: Codable {
        let profileImage: ProfileImage

        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }
    
    struct ProfileImage: Codable {
        let small: URL
    }
    
    func makeProfileImageRequest(token: String) -> URLRequest? {
        nickname = profileService.profileData?.username
        let url = URL(string: "https://api.unsplash.com/users/\(nickname!)")!
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
                    self.avatarURL = imageResult.profileImage.small.absoluteString
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
        }
        self.task = task
        task.resume()
    }
    
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
