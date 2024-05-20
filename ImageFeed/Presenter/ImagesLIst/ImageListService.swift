//
//  ImageListService.swift
//  ImageFeed
//
//  Created by Архип Семёнов on 17.05.2024.
//

import Foundation

final class ImageListService {
    
    struct Photo {
        let id: String
        let size: CGSize
        let createdAt: Date?
        let welcomeDescription: String?
        let thumbImageURL: String
        let largeImageURL: String
        let isLiked: Bool
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
    
    //MARK: Properties
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private var lastLoadedPage: Int = 0
    private var isFetching = false
    private (set) var photos: [Photo] = []
    
    
    //MARK: Methods
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
        
        let urlString = "https://api.unsplash.com/photos?page=\(lastLoadedPage)&per_page=10&order_by=latest"
        
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
                        largeImageURL: photoResult.urls.full,
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



