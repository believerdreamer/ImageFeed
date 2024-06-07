//
//  ProfileViewTests.swift
//  ImageFeedTests
//
//  Created by Архип Семёнов on 31.05.2024.
//

import XCTest
@testable import ImageFeed

final class ProfileViewPresenterSpy: ProfilePresenterProtocol {
    
    var view: (any ImageFeed.ProfileViewControllerProtocol)?
    var profile: ImageFeed.Profile?
    var avatarURL: String?
    var cleanCacheCalled: Bool = false
    var viewDidLoadCalled: Bool = false
    
    func clearCache() {
    cleanCacheCalled = true
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    
}
