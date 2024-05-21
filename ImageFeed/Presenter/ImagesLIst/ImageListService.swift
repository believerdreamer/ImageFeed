import Foundation

final class ImageListService {
    
    struct Photo {
        let id: String
        let size: CGSize
        let createdAt: Date?
        let welcomeDescription: String?
        let thumbImageURL: String
        let fullImageURL: String
        let regularImageURL: String
        var isLiked: Bool
    }
    
    struct UrlResult: Codable {
        let raw: String
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }
    
    struct PhotoResult: Codable {
        let id: String
        let createdAt: String
        let welcomeDescription: String?
        let urls: UrlResult
        
        enum CodingKeys: String, CodingKey {
            case id
            case createdAt = "created_at"
            case welcomeDescription = "description"
            case urls
        }
    }
    
    // MARK: Properties
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let shared = ImageListService()
    private var lastLoadedPage: Int = 0
    private var isFetching = false
    private let semaphore = DispatchSemaphore(value: 1)
    var photos: [Photo] = []
    
    // MARK: Methods
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        UIBlockingPorgressHUD.show()
        
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            UIBlockingPorgressHUD.dismiss()
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(OAuth2TokenStorage().token ?? "default token")", forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = isLike ? "POST" : "DELETE"
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            defer {
                UIBlockingPorgressHUD.dismiss()
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
    
    private func updatePhotos(_ newPhotos: [Photo]){
        DispatchQueue.main.async {
            self.photos.append(contentsOf: newPhotos)
            NotificationCenter.default.post(name: ImageListService.didChangeNotification, object: nil)
            self.isFetching = false
        }
    }
    
    func fetchPhotosNextPage() {
        guard !isFetching else { return }
        
        isFetching = true
        lastLoadedPage += 1
        
        let urlString = "https://api.unsplash.com/photos?page=\(lastLoadedPage)&per_page=20&order_by=latest"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            isFetching = false
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(OAuth2TokenStorage().token ?? "default token")", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                self.isFetching = false
                return
            }
            
            guard let data = data else {
                print("No data received")
                self.isFetching = false
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let photoResults = try decoder.decode([PhotoResult].self, from: data)
                let newPhotos: [Photo] = photoResults.compactMap { photoResult in
                    guard let date = ISO8601DateFormatter().date(from: photoResult.createdAt) else {
                        print("Error converting createdAt to Date")
                        return nil
                    }
                    
                    return Photo(
                        id: photoResult.id,
                        size: .zero,
                        createdAt: date,
                        welcomeDescription: photoResult.welcomeDescription,
                        thumbImageURL: photoResult.urls.thumb,
                        fullImageURL: photoResult.urls.full,
                        regularImageURL: photoResult.urls.regular,
                        isLiked: false
                    )
                }
                self.updatePhotos(newPhotos)
            } catch {
                print("Error decoding JSON: \(error)")
                self.isFetching = false
            }
        }
        task.resume()
    }
}
