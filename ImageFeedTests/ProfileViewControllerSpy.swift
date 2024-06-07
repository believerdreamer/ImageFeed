//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Архип Семёнов on 31.05.2024.
//

import XCTest
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    
    var presenter: ProfilePresenterProtocol?
    var updateAvatarCalled = false
    var updateProfileDataCalled = false
    var clearCacheCalled = false
    
    func updateAvatar(url: String?) {
        updateAvatarCalled = true
    }
    
    func updateProfileData(data: Profile) {
        updateProfileDataCalled = true
    }
    
    func clearCache() {
        clearCacheCalled = true
    }
}
