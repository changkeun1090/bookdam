//
//  PersistantManager.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/13/25.
//

import Foundation
import UIKit

// Enum to represent sort order options
enum SortOrder: String {
    case newest = "newest"
    case oldest = "oldest"
}

enum DisplayMode: Int, CaseIterable {
    case system
    case light
    case dark
    
    // Add title property here
    var title: String {
        switch self {
        case .system:
            return "시스템 설정"
        case .light:
            return "라이트 모드"
        case .dark:
            return "다크 모드"
        }
    }
    
    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return .unspecified
        }
    }
    
    static func from(_ style: UIUserInterfaceStyle) -> DisplayMode {
        switch style {
        case .light:
            return .light
        case .dark:
            return .dark
        default:
            return .system
        }
    }
}

final class UserDefaultsManager {
    
    // MARK: - Singleton
    static let shared = UserDefaultsManager()
    private init() {}
    
    // MARK: - UserDefaults Keys
    private enum Keys {
        static let sortOrder = "preferredSortOrder"
        static let displayMode = "displayMode"
    }
    
    // MARK: - Sort Order
    var sortOrder: SortOrder {
        get {
            let savedValue = UserDefaults.standard.string(forKey: Keys.sortOrder)
            return SortOrder(rawValue: savedValue ?? "") ?? .newest
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.sortOrder)
        }
    }
    
    // MARK: - Display Mode
    var displayMode: DisplayMode {
        get {
            let rawValue = UserDefaults.standard.integer(forKey: Keys.displayMode)
            return DisplayMode(rawValue: rawValue) ?? .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.displayMode)
            applyDisplayMode(newValue)
        }
    }
    
    // MARK: - Helper Methods
    private func applyDisplayMode(_ mode: DisplayMode) {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first(where: { $0.isKeyWindow })
        
        window?.overrideUserInterfaceStyle = mode.interfaceStyle
    }
}
