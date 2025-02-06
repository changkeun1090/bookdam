//
//  Constant.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/3/25.
//

import Foundation
import UIKit

enum DeviceType {
    case phone
    case padMini      // iPad mini
    case padRegular   // Regular iPad and iPad Air
    case padLarge     // iPad Pro 12.9"
    
    static var current: DeviceType {
        let device = UIDevice.current
        guard device.userInterfaceIdiom == .pad else { return .phone }
        
        let screenWidth = UIScreen.main.bounds.width
        switch screenWidth {
        case ..<745:  return .padMini     // iPad mini width: 744 points
        case ..<1024: return .padRegular  // Regular iPad width: 810 points
        default:      return .padLarge    // iPad Pro 12.9" width: 1024+ points
        }
    }
    
    var fontScale: CGFloat {
        switch self {
        case .phone:      return 1.0
        case .padMini:    return 1.2
        case .padRegular: return 1.4
        case .padLarge:   return 1.6
        }
    }
    
    var columnCount: (card: CGFloat, detail: CGFloat) {
        switch self {
        case .phone:
            return (card: 3, detail: 2)
        case .padMini, .padRegular:
            return (card: 4, detail: 3)
        case .padLarge:
            return (card: 5, detail: 3)
        }
    }
    
    var gutter: CGFloat {
        switch self {
        case .phone:
            return Constants.Layout.gutter
        case .padMini:
            return 20
        case .padRegular:
            return 24
        case .padLarge:
            return 24
        }
    }
}

struct Constants {
    struct Colors {
        
        static let mainBackground = UIColor.systemBackground
        static let subBackground = UIColor.secondarySystemBackground
        
        static let tagBackground = UIColor.secondarySystemFill
        static let tagText = UIColor.secondaryLabel
        static let tagSelectedBackground = UIColor.systemBlue
        static let tagSelettedText = UIColor.lightText
        
        static let accent = UIColor.systemBlue
        static let warning = UIColor.systemRed
        
        static let darkText = UIColor.darkText        
        static let subText = UIColor.systemGray
        
        static let border = UIColor.systemGray
    }
    
    struct Layout {
        static let layoutMargin: CGFloat = 16
        static let gutter: CGFloat = 16
        
        static let extraSmMargin: CGFloat = 4
        static let smMargin: CGFloat = 8
        static let mdMargin: CGFloat = 16
        static let lgMargin: CGFloat = 32
    }
    
    enum FontSize {
        case title
        case largeBody
        case body
        case smallBody
        
        private var baseSize: CGFloat {
            switch self {
            case .title:      return 24
            case .largeBody:  return 20
            case .body:       return 16
            case .smallBody:  return 14
            }
        }
        
        var size: CGFloat {
            return baseSize * DeviceType.current.fontScale
        }
    }

    struct Fonts {
        // Title
        static var title: UIFont {
            .systemFont(ofSize: FontSize.title.size, weight: .bold)
        }
        
        // Large Body
        static var largeBody: UIFont {
            .systemFont(ofSize: FontSize.largeBody.size, weight: .regular)
        }
        
        static var largeBodyBold: UIFont {
            .systemFont(ofSize: FontSize.largeBody.size, weight: .bold)
        }
        
        // Body
        static var body: UIFont {
            .systemFont(ofSize: FontSize.body.size, weight: .regular)
        }
        
        static var bodyBold: UIFont {
            .systemFont(ofSize: FontSize.body.size, weight: .bold)
        }
        
        // Small Body
        static var smallBody: UIFont {
            .systemFont(ofSize: FontSize.smallBody.size, weight: .regular)
        }
        
        static var smallBodyBold: UIFont {
            .systemFont(ofSize: FontSize.smallBody.size, weight: .bold)
        }
    }
    
    struct Icons {
        static let tag = "tag"
        static let more = "ellipsis.circle"
        static let search = "magnifyingglass"
        static let orderList = "arrow.up.arrow.down"
        static let chevronForward = "chevron.forward"
        static let chevronBackward = "chevron.backward"
        static let check = "checkmark"
        static let checkWithCircle = "checkmark.circle"
        static let addTag = "plus.app"
        static let xmark = "x.circle"
    }

    // MARK: - Book Image Size
    
    enum BookImageType {
        case card
        case detail
        
        var columnCount: CGFloat {
            switch DeviceType.current {
            case .phone:
                return self == .card ? 3 : 2
            case .padMini, .padRegular:
                return self == .card ? 4 : 3
            case .padLarge:
                return self == .card ? 5 : 4
            }
        }
    }

    struct BookImageSize {
        static let aspectRatio: CGFloat = 125.0 / 85.0
        
        static func calculate(
            type: BookImageType
        ) -> (width: CGFloat, height: CGFloat) {
            
            let padding = Constants.Layout.layoutMargin * 2
            
            let gutter = DeviceType.current.gutter
            
            let containerWidth = UIScreen.main.bounds.width
            
            let totalSpacing = padding + (gutter * (type.columnCount - 1))
            let itemWidth = floor((containerWidth - totalSpacing) / type.columnCount)
            let itemHeight = itemWidth * aspectRatio
            
            return (itemWidth, itemHeight)
        }
    }
    
    struct Systems {
        static let iCloudContainer = "iCloud.com.changkeun.BookDam"
    }
    
    struct Configuration {
        static let icon = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        static let largeIcon = UIImage.SymbolConfiguration(pointSize: 36, weight: .regular)
    }

}
