//
//  Constant.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/3/25.
//

import Foundation
import UIKit

struct Constants {
    struct Colors {
//        static let mainBackground = UIColor.secondarySystemBackground
//        static let subBackground = UIColor.tertiarySystemBackground
        
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
    
    struct Fonts {
        static let title = UIFont.systemFont(ofSize: 24, weight: .bold)
        
        static let largeBody = UIFont.systemFont(ofSize: 20, weight: .regular)
        static let largeBodyBold = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        static let body = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let bodyBold = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        static let smallBody = UIFont.systemFont(ofSize: 14, weight: .regular)
        static let smallBodyBold = UIFont.systemFont(ofSize: 14, weight: .bold)
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
    
    enum DeviceType {
        case phone
        case pad
        
        static var current: DeviceType {
            return UIDevice.current.userInterfaceIdiom == .pad ? .pad : .phone
        }
        
        var columnCount: (card: CGFloat, detail: CGFloat) {
            switch self {
            case .phone:
                return (card: 3, detail: 2)
            case .pad:
                return (card: 4, detail: 3)
            }
        }
    }
    
    // MARK: - Book Image Size
    
    enum BookImageType {
        case card
        case detail
        
        var columnCount: CGFloat {
            switch DeviceType.current {
            case .phone:
                return self == .card ? 3 : 2
            case .pad:
                return self == .card ? 4 : 3
            }
        }
    }

    struct BookImageSize {
        static let aspectRatio: CGFloat = 125.0 / 85.0
        
        static func calculate(
            type: BookImageType,
            gutter: CGFloat = Constants.Layout.gutter
        ) -> (width: CGFloat, height: CGFloat) {
            
            let padding = Constants.Layout.layoutMargin * 2
            let gutter = DeviceType.current == .pad ? 24 : Constants.Layout.gutter
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
