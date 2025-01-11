//
//  DataLoadingVC.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/8/25.
//

import UIKit

class DataLoadingVC: UIViewController {
    
    var containerView: UIView!
    
    func showLoadingView() {
        containerView = UIView(frame: view.bounds)
        
        view.addSubview(containerView)
        
        containerView.backgroundColor = .systemBackground
        containerView.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            self.containerView.alpha = 0.8
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
        ])
        
        activityIndicator.startAnimating()
    }
    
    func dismissLoadingView() {
        DispatchQueue.main.async {
            self.containerView.removeFromSuperview()
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


