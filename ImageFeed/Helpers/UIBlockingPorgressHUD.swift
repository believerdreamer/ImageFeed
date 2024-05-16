//
//  UIBlockingPorgressHUD.swift
//  ImageFeed
//
//  Created by Архип Семёнов on 17.04.2024.
//

import UIKit
import ProgressHUD

final class UIBlockingPorgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.show()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
