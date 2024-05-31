//
//  ImageListViewTests.swift
//  ImageFeedTests
//
//  Created by Архип Семёнов on 31.05.2024.
//

import XCTest
@testable import ImageFeed

final class ImageListViewTests: XCTestCase {
    func testImagesListViewControllerCallsViewDidLoad() {
        // Given
        let viewController = ImageListViewControllerSpy()
        let presenter = ImageListViewPresenterSpy()
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        viewController.viewDidLoad()
        
        // Then
        XCTAssertTrue(presenter.didFetchPhotosNextPageCalled, "fetchPhotosNextPage should be called on viewDidLoad")
        XCTAssertTrue(presenter.didClearCacheCalled, "clearCache should be called on viewDidLoad")
    }

    func testImagesListViewControllerCallsLikeButtonTapped() {
        // Given
        let viewController = ImageListViewControllerSpy()
        let presenter = ImageListViewPresenterSpy()
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        viewController.likeButtonTapped(UIButton())
        
        // Then
        XCTAssertTrue(presenter.didLikeButtonTappedCalled, "likeButtonTapped should be called when like button is tapped")
    }
}
