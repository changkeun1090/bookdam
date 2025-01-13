//
//  PersistantManager.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/13/25.
//

import Foundation

// Enum to represent sort order options
enum SortOrder: String {
    case newest = "newest"
    case oldest = "oldest"
}

// Class to manage all UserDefaults operations
final class UserDefaultsManager {
    
    // MARK: - Singleton
    static let shared = UserDefaultsManager()
    private init() {}
    
    // MARK: - UserDefaults Keys
    private enum Keys {
        static let sortOrder = "preferredSortOrder"
        // You can add more keys here as needed
    }
    
    // MARK: - Sort Order
    var sortOrder: SortOrder {
        get {
            // Read from UserDefaults, default to .newest if no value is stored
            let savedValue = UserDefaults.standard.string(forKey: Keys.sortOrder)
            return SortOrder(rawValue: savedValue ?? "") ?? .newest
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.sortOrder)
        }
    }
}
