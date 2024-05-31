//
//  ProfileViewTests.swift
//  ImageFeedTests
//
//  Created by Архип Семёнов on 31.05.2024.
//

import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    
    var presenter: ProfilePresenter!
    var view: ProfileViewControllerSpy!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        view = ProfileViewControllerSpy()
        presenter = ProfilePresenter(view: view)
        view.presenter = presenter
    }
    
    func testViewControllerCallsViewDidLoad(){
        //Given
        let viewController = ImageFeed.ProfileViewContoller()
        let presenter = ProfileViewPresenterSpy()
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        _ = viewController.view
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCleanCache() {
        // Given
        let viewController = ImageFeed.ProfileViewContoller()
        let presenter = ProfileViewPresenterSpy()
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        presenter.clearCache()
        
        // Then
        XCTAssertTrue(presenter.cleanCacheCalled)
    }
    
    func testAvatarAndProfileDataLoad() {
        // Given
        let profile = Profile(username: "usernname", name: "name", loginName: "loginName", bio: "bio")
        presenter.profileService.profileData = profile
        presenter.profileImageService.avatarURL = "https://example.com/avatar.jpg"
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(view.updateProfileDataCalled, "updateProfileData should be called")
        XCTAssertTrue(view.updateAvatarCalled, "updateAvatar should be called")
    }
    
}
