//
//  LeftAlignedFlowLayout.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/15/25.
//

import Foundation
import UIKit

final class LeftAlignedFlowLayout: UICollectionViewFlowLayout {
    
    private let fixedHeight: CGFloat = 36 // Adjust this value as needed

    // MARK: - Layout Attributes
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let originalAttributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        let attributes = originalAttributes.map { $0.copy() as! UICollectionViewLayoutAttributes }
        
        var leftMargin: CGFloat = sectionInset.left
        var maxY: CGFloat = -1.0
        
        attributes.forEach { layoutAttribute in
            guard layoutAttribute.representedElementCategory == .cell else {
                return
            }
            
            if layoutAttribute.frame.minY >= maxY {
                leftMargin = sectionInset.left
            }
                        
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
