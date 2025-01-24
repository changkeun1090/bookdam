//
//  AppDelegate.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/3/25.
//

import UIKit
import CoreData
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let backgroundTaskIdentifier = "com.changkeun.bookdam.refresh"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Register background task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: AppDelegate.backgroundTaskIdentifier, using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack
    
    /*
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: Constants.Systems.iCloudContainer)
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        // Enable automatic cloud sync
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
     */
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        return CoreDataManager.shared.persistentContainer
    }()
    
    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                // Ensure we're on the main thread
                if Thread.isMainThread {
                    try context.save()
                } else {
                    DispatchQueue.main.sync {
                        try? context.save()
                    }
                }
             } catch {
                 let nserror = error as NSError
                 fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
             }
        }
    }
    
    // MARK: - Background Task Handling
    private func handleAppRefresh(task: BGAppRefreshTask) {
        // Create a task assertion to track background task
        task.expirationHandler = {
            // Handle background task expiration
            task.setTaskCompleted(success: false)
        }
        
        // Schedule next background task
        scheduleAppRefresh()
        
        let context = persistentContainer.viewContext
        
        // Check for any changes in CloudKit
        context.performAndWait {
            if context.hasChanges {
                do {
                    try context.save()
                    task.setTaskCompleted(success: true)
                } catch {
                    print("Background task error: \(error)")
                    task.setTaskCompleted(success: false)
                }
            } else {
                task.setTaskCompleted(success: true)
            }
        }
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: AppDelegate.backgroundTaskIdentifier)
        // Set the earliest begin date to 15 minutes from now
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }

}


