//
//  WebViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Архип Семёнов on 03.06.2024.
//

import Foundation
import ImageFeed

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var view: (any ImageFeed.WebViewViewControllerProtocol)?
    var viewDidLoadCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {}
    
    func code(from url: URL) -> String? {
        return nil
    }
}
