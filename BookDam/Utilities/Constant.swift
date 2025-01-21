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
        static let mainBackground = UIColor.secondarySystemBackground
        static let subBackground = UIColor.tertiarySystemBackground
        
        static let tagBackground = UIColor.secondarySystemFill
        static let tagText = UIColor.secondaryLabel
        static let tagSelectedBackground = UIColor.systemBlue
        static let tagSelettedText = UIColor.lightText
        
        static let accent = UIColor.systemBlue
        static let warning = UIColor.systemRed
        
        static let mainText = UIColor.darkText
        static let subText = UIColor.systemGray
        
        static let border = UIColor.systemGray
    }
    
    struct Layout {
        static let layoutMargin: CGFloat = 16
        static let gutter: CGFloat = 24
        
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
    
    struct Size {
        // Static function to calculate the image size based on fixed screen width
        static func calculateImageSize(padding: CGFloat = Constants.Layout.layoutMargin * 2, gutter: CGFloat = Constants.Layout.gutter, itemCount:CGFloat = 3) -> (width: CGFloat, height: CGFloat) {
            
            // Get the fixed screen width
            let containerWidth = UIScreen.main.bounds.width
            
            // Calculate total spacing between items
            let totalSpacing = padding + (gutter * (itemCount - 1))
            
            // Calculate item width based on the container's width (fixed screen width)
            let itemWidth = floor((containerWidth - totalSpacing) / itemCount)
            
            // Calculate item height based on a fixed aspect ratio (40:27)
            let itemHeight = itemWidth * (125.0 / 85.0)
            
            return (itemWidth, itemHeight)
        }
        
        static func calculateImageSizeWithWidth(for containerWidth: CGFloat, padding: CGFloat = 16 * 2, gutter: CGFloat = 16, itemCount: CGFloat = 3) -> (width: CGFloat, height: CGFloat) {
            
            // Calculate total spacing between items
            let totalSpacing = padding + (gutter * (itemCount - 1))
            
            // Calculate item width based on the container's width
            let itemWidth = floor((containerWidth - totalSpacing) / itemCount)
            
            // Calculate item height based on a fixed aspect ratio (40:27)
            let itemHeight = itemWidth * (40.0 / 27.0)
            
            return (itemWidth, itemHeight)
        }
    }
    
    struct Configuration {
        static let icon = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        static let largeIcon = UIImage.SymbolConfiguration(pointSize: 36, weight: .regular)
    }

}
