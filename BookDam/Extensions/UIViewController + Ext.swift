//
//  UIViewController + Ext.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/10/25.
//

import UIKit
import SafariServices

extension UIViewController {
    /*
    func presentGFAlertOnMainThread(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let alertVC = GFAlertVC(title: title, message: message, buttonTitle: buttonTitle)
            alertVC.modalPresentationStyle = .overFullScreen // avoids card style in iOS 13
            alertVC.modalTransitionStyle = .crossDissolve // fades in
            self.present(alertVC, animated: true)
        }
    }
     */
    
    func showConfirmationAlert(title: String, message: String, confirmActionTitle: String, cancelActionTitle: String, confirmHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: confirmActionTitle, style: .destructive) { _ in
            confirmHandler()
        }
        
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showInfoAlert(title: String, message: String, buttonTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
        alertController.addAction(action)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showAutoDismissAlert(title: String, message: String, duration: TimeInterval = 2.0) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        present(alertController, animated: true, completion: nil)
        
        // Dismiss the alert after the specified duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            alertController.dismiss(animated: true, completion: nil)
        }
    }
    
    func presentSafariVC(with url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = .systemGreen
        present(safariVC, animated: true)
    }
}
