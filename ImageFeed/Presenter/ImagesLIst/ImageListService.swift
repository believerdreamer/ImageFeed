import Foundation

final class ImageListService {
    
    // MARK: - Private Properties
    private var lastLoadedPage: Int = 0
    private var isFetching = false
    
    // MARK: - Public Properties
    
    var photos: [Photo] = []
    
    // MARK: - Private Constants
    
    private let semaphore = DispatchSemaphore(value: 1)
    
    // MARK: - Public Constatnts
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let shared = ImageListService()
    
    // MARK: Public Functions
    
    func fetchPhotosNextPage(completion: @escaping (Result<Void, Error>) -> Void) {
        guard !isFetching else { return }
        
        isFetching = true
        lastLoadedPage += 1
        
        let urlString = "https://api.unsplash.com/photos?page=\(lastLoadedPage)&per_page=10&order_by=latest"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            isFetching = false
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        
        let tokenStorage = OAuth2TokenStorage()
        if let token = tokenStorage.token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Error getting token: Token is nil")
            isFetching = false
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token is nil"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                self.isFetching = false
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data received")
                self.isFetching = false
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let photoResults = try decoder.decode([PhotoResult].self, from: data)
                
                let dateFormatter = ISO8601DateFormatter()
                let newPhotos: [Photo] = photoResults.compactMap { photoResult in

                    let date = dateFormatter.date(from: photoResult.createdAt ?? "Нет даты")
                    return Photo(
                        id: photoResult.id,
                        size: .zero,
                        createdAt: date,
                        welcomeDescription: photoResult.welcomeDescription,
                        thumbImageURL: photoResult.urls.thumb,
                        fullImageURL: photoResult.urls.full,
                        regularImageURL: photoResult.urls.regular,
                        smallImageURL: photoResult.urls.small,
                        isLiked: false
                    )
                }
                self.updatePhotos(newPhotos)
                completion(.success(()))
            } catch {
                print("Error decoding JSON: \(error)")
                self.isFetching = false
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(OAuth2TokenStorage().token ?? "default token")", forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = isLike ? "POST" : "DELETE"
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            defer {
                
            }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to change like status: Invalid response"])))
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(()))
            }
        }
        task.resume()
    }
    
    func updatePhotoLikeStatus(photoId: String, isLiked: Bool) {
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            photos[index].isLiked = isLiked
            NotificationCenter.default.post(name: ImageListService.didChangeNotification, object: nil)
        }
    }
    // MARK: - Private Methods
    
    private func updatePhotos(_ newPhotos: [Photo]){
        DispatchQueue.main.async {
            self.photos.append(contentsOf: newPhotos)
            NotificationCenter.default.post(name: ImageListService.didChangeNotification, object: nil)
            self.isFetching = false
        }
    }
}
