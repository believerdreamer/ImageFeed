//
//  ImageListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Архип Семёнов on 31.05.2024.
//

import XCTest
@testable import ImageFeed

final class ImageListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    var photos: [Photo] = []
    var tableView: UITableView!
    var didLikeButtonTappedCalled: Bool = false
    var didClearCacheCalled: Bool = false

    init() {
        tableView = UITableView()
    }

    func viewDidLoad() {
        presenter?.fetchPhotosNextPage()
        presenter?.clearCache()
    }

    func likeButtonTapped(_ sender: UIButton) {
        didLikeButtonTappedCalled = true
        presenter?.likeButtonTapped(sender)
    }

    func clearCache() {
        didClearCacheCalled = true
    }
}
