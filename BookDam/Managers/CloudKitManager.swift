//
//  CloudKitManager.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/22/25.
//

import Foundation
import CloudKit
import CoreData

extension Notification.Name {
    static let cloudKitSyncStatusChanged = Notification.Name("cloudKitSyncStatusChanged")
}


class CloudKitManager {
    static let shared = CloudKitManager()
    private var debounceTimer: Timer?
    private var lastHistoryToken: NSPersistentHistoryToken?

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
        debounceTimer?.invalidate()
        
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.processPendingChanges()
        }
    }
    
    private func processPendingChanges() {
        let context = CoreDataManager.shared.persistentContainer.newBackgroundContext()
        context.performAndWait {
            do {
                let request = NSPersistentHistoryChangeRequest.fetchHistory(after: lastHistoryToken)
                let result = try context.execute(request) as? NSPersistentHistoryResult
                guard let transactions = result?.result as? [NSPersistentHistoryTransaction] else { return }
                
                // Check if any changes affect our entities
                let hasRelevantChanges = transactions.contains { transaction in
                    transaction.changes?.contains { change in
                        return change.changedObjectID.entity.name == "BookEntity" ||
                               change.changedObjectID.entity.name == "TagEntity"
                    } ?? false
                }
                
                if hasRelevantChanges {
                    BookManager.shared.loadBooks()
                    TagManager.shared.loadTags()
                }
                
                // Update token
                lastHistoryToken = transactions.last?.token
                
            } catch {
                print("Error checking history: \(error)")
            }
        }
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
        checkiCloudStatus { [weak self] isAvailable in
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
