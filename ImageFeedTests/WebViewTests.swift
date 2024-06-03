//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Архип Семёнов on 27.05.2024.
//

import XCTest
@testable import ImageFeed

final class WebViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        _ = viewController.view
        
        // Then
        
        XCTAssert(presenter.viewDidLoadCalled)
    }
    
    func testProgressVisibleWhenLessOne() {
        //Given
        let helper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: helper)
        let progress: Float = 0.6
        
        // When
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        // Then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        // Given
        let helper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: helper)
        let progress: Float = 1
        
        //When
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //Then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        // Given
        let config = AuthConfiguration.standart
        let helper = AuthHelper(configuration: config)
        
        // When
        let url = helper.authURL()
        
        // Then
        if let urlString = url?.absoluteString{
            XCTAssertTrue(urlString.contains(config.authURLString))
            XCTAssertTrue(urlString.contains(config.accessKey))
            XCTAssertTrue(urlString.contains(config.redirectURI))
            XCTAssertTrue(urlString.contains("code"))
            XCTAssertTrue(urlString.contains(config.accessScope))
        } else {
            XCTFail("URL string is nil")
        }
    }
    
    func testCodeFromURL() {
        // Given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
        let helper = AuthHelper()
        
        // When
        let code = helper.code(from: url)
        
        // Then
        XCTAssertEqual(code, "test code")
    }
}

