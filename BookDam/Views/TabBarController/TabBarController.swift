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
        UITabBar.appearance().backgroundColor = Constants.Colors.subBackground
        
        viewControllers = [createBookNC(), createSearchNC(), createInfoNC()]
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
    
    func createInfoNC() -> UINavigationController {
        let infoVC = InfoVC()
        let infoIcon = UIImage(systemName: "ellipsis.circle")
        infoVC.tabBarItem = UITabBarItem(title: nil, image: infoIcon , tag: 2)
        return UINavigationController(rootViewController: infoVC)
    }
}

// MARK: - UITabBarControllerDelegate
extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Check if we're tapping the same tab we're currently on
        if viewController == tabBarController.selectedViewController {
            // Get the navigation controller
            if let navController = viewController as? UINavigationController {
                // Get the root view controller (BooksVC)
                if let booksVC = navController.viewControllers.first as? BooksVC {
                    // Tell BooksVC to scroll to top
                    booksVC.scrollToTop()
                }
            }
        }
        return true
    }
}
