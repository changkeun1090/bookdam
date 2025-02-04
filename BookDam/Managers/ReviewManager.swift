//
//  File.swift
//  BookDam
//
//  Created by ChangKeun Ji on 2/4/25.
//

import StoreKit

class ReviewManager {
    static let shared = ReviewManager()
    private let userDefaults = UserDefaults.standard
    private let lastReviewRequestDateKey = "lastReviewRequestDate"
    
    private init() {}
    
    func requestReviewIfNeeded() {
        let lastRequestDate = userDefaults.object(forKey: lastReviewRequestDateKey) as? Date
  
//        DispatchQueue.main.async {
//            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
//                SKStoreReviewController.requestReview(in: scene)
//            }
//            self.userDefaults.set(Date(), forKey: self.lastReviewRequestDateKey)
//        }
        
        // Check if enough time has passed since the last review request (6 months)
        let shouldRequestReview = lastRequestDate == nil ||
            Calendar.current.dateComponents([.day], from: lastRequestDate!, to: Date()).day! >= 30
        
        if shouldRequestReview {
            DispatchQueue.main.async {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
                
                // Update last request date
                self.userDefaults.set(Date(), forKey: self.lastReviewRequestDateKey)
            }
        }
    }
}
