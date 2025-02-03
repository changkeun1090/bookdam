//
//  DataLoadingVC.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/8/25.
//

import UIKit

class DataLoadingVC: UIViewController {
    
    var containerView: UIView?
    
    func showLoadingView() {
        // Check if container view already exists
        guard containerView == nil else { return }
        
        // Create new container and store it in a local constant
        let container = UIView(frame: view.bounds)
        
        // Store in the optional property
        containerView = container
        
        view.addSubview(container)
        
        container.backgroundColor = .systemBackground
        container.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            container.alpha = 0.8
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
        ])
        
        activityIndicator.startAnimating()
    }
    
    func dismissLoadingView() {
        DispatchQueue.main.async {
            self.containerView?.removeFromSuperview()
            self.containerView = nil
        }
    }
}


//    func showEmptyStateView(with message: String, in view: UIView) {
//        let emptyStateView = GFEmptyStateView(message: message)
//        emptyStateView.frame = view.bounds
//        // fill the whole screen
//        view.addSubview(emptyStateView)
//    }


