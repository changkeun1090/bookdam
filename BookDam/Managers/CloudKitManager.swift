//
//  CloudKitManager.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/22/25.
//

import Foundation
import CloudKit

extension Notification.Name {
    static let cloudKitSyncStatusChanged = Notification.Name("cloudKitSyncStatusChanged")
}


class CloudKitManager {
    static let shared = CloudKitManager()
    
    private(set) var isSyncing = false {
        didSet {
            NotificationCenter.default.post(
                name: .cloudKitSyncStatusChanged,
                object: nil,
                userInfo: ["isSyncing": isSyncing]
            )
        }
    }
    
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
    
    func triggerSync(completion: @escaping (Error?) -> Void) {
        CloudKitManager.shared.checkiCloudStatus { [weak self] isAvailable in
            guard let self = self else { return }
            
            if isAvailable {
                self.isSyncing = true
                
                let context = CoreDataManager.shared.persistentContainer.viewContext
                
                if context.hasChanges {
                    do {
                        try context.save()
                    } catch {
                        DispatchQueue.main.async {
                            self.isSyncing = false
                            completion(error)
                        }
                        return
                    }
                }
                
                // Give some time for the sync to propagate
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.isSyncing = false
                    completion(nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(NSError(
                        domain: "CloudKitManager",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "iCloud is not available"]
                    ))
                }
            }
        }
    }
}
