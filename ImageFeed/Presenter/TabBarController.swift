//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Архип Семёнов on 10.05.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imageListVC = storyboard.instantiateViewController(withIdentifier: "ImageListViewController")
        imageListVC.tabBarItem.image = UIImage(named: "tab_editorial_active")
        imageListVC.tabBarItem.title = ""
        
        let profileVC = ProfileViewController()
        profileVC.tabBarItem.image = UIImage(named: "tab_profile_active")
        
        self.viewControllers = [imageListVC, profileVC]
    }
}
