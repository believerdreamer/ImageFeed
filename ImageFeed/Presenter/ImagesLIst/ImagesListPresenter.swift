//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Архип Семёнов on 30.05.2024.
//

import UIKit
import Kingfisher

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var imageListService = ImageListService.shared
    
    init(view: ImagesListViewControllerProtocol?) {
        self.view = view
    }
    
    @objc func likeButtonTapped(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? ImagesListCell,
              let indexPath = view?.tableView.indexPath(for: cell) else {
            return
        }
        
        var photo = imageListService.photos[indexPath.row]
        let shouldLike = !photo.isLiked
        UIBlockingPorgressHUD.show()
        imageListService.changeLike(photoId: photo.id, isLike: shouldLike) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingPorgressHUD.dismiss()
                switch result {
                case .success:
                    photo.isLiked = shouldLike
                    self?.imageListService.photos[indexPath.row] = photo
                    cell.likeButton.setImage(shouldLike ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off"), for: .normal)
                case .failure(let error):
                    print("Failed to change like status: \(error)")
                }
            }
        }
    }
    
    func clearCache() {
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
    }
    
    func formatDate() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }
}
