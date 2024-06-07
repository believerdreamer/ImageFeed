//
//  ImageListViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Архип Семёнов on 31.05.2024.
//

import XCTest
@testable import ImageFeed


final class ImageListViewPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var imageListService: ImageListService?
    var didLikeButtonTappedCalled: Bool = false
    var didFetchPhotosNextPageCalled: Bool = false
    var didClearCacheCalled: Bool = false
    var didFormatDateCalled: Bool = false

    func likeButtonTapped(_ sender: UIButton) {
        didLikeButtonTappedCalled = true
    }

    func fetchPhotosNextPage() {
        didFetchPhotosNextPageCalled = true
    }

    func clearCache() {
        didClearCacheCalled = true
    }

    func formatDate() -> DateFormatter {
        didFormatDateCalled = true
        return DateFormatter()
    }
}
