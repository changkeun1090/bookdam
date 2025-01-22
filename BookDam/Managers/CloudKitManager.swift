//
//  CloudKitManager.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/22/25.
//

import Foundation
import CloudKit

class CloudKitManager {
    static let shared = CloudKitManager()
    
    private init() {
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStoreRemoteChange),
            name: .NSPersistentStoreRemoteChange,
            object: nil
        )
    }
    
    @objc private func handleStoreRemoteChange(_ notification: Notification) {
        // Notify relevant managers about changes
        BookManager.shared.loadBooks()
        TagManager.shared.loadTags()
    }
    
    func checkiCloudStatus(completion: @escaping (Bool) -> Void) {
        CKContainer.default().accountStatus { (accountStatus, error) in
            DispatchQueue.main.async {
                switch accountStatus {
                case .available:
                    completion(true)
                default:
                    completion(false)
                }
            }
        }
    }
}
