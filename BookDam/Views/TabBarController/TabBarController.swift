//
//  TabBarController.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/3/25.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        UITabBar.appearance().tintColor = Constants.Colors.accent      
        UITabBar.appearance().barTintColor = Constants.Colors.mainBackground
        UITabBar.appearance().unselectedItemTintColor = Constants.Colors.subText
        UITabBar.appearance().backgroundColor = Constants.Colors.mainBackground
        
        viewControllers = [createBookNC(), createSearchNC(), createMoreNC()]
    }
     
    func createBookNC() -> UINavigationController {
        let booksVC = BooksVC()
        let bookIcon = UIImage(systemName: "book")
        booksVC.tabBarItem = UITabBarItem(title: nil, image: bookIcon , tag: 0)
        return UINavigationController(rootViewController: booksVC)
    }
    
    func createSearchNC() -> UINavigationController {
        let searchVC = SearchVC()
        let searchIcon = UIImage(systemName: "plus.circle")
        searchVC.tabBarItem = UITabBarItem(title: nil, image: searchIcon , tag: 1)
        return UINavigationController(rootViewController: searchVC)
    }
    
    func createMoreNC() -> UINavigationController {
        let moreVC = MoreVC()
        let infoIcon = UIImage(systemName: "list.bullet")
        moreVC.tabBarItem = UITabBarItem(title: nil, image: infoIcon , tag: 2)
        return UINavigationController(rootViewController: moreVC)
    }
}

// MARK: - UITabBarControllerDelegate
extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == tabBarController.selectedViewController {
            if let navController = viewController as? UINavigationController {
                
                if let booksVC = navController.viewControllers.first as? BooksVC {
                    booksVC.scrollToTop()
                }
                
                if let searchVC = navController.viewControllers.first as? SearchVC {
                    searchVC.scrollToTop()
                }
            }
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navController = viewController as? UINavigationController {
            navController.popToRootViewController(animated: false)
        }
    }
}


