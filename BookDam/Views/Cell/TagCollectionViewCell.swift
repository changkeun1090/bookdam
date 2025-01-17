//
//  TagCollectionViewCell.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/15/25.
//

import Foundation
import UIKit

class TagCollectionViewCell: UICollectionViewCell { 
    static let identifier = "TagCollectionViewCell"

    var tagId: UUID?

    // MARK: - UI Components
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.smallBodyBold
        label.textColor = Constants.Colors.tagText
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Selection State
    var isTagSelected: Bool = false {
        didSet {
            updateVisualState()
        }
    }
        
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.backgroundColor = Constants.Colors.tagBackground
        contentView.layer.cornerRadius = 15
        contentView.clipsToBounds = true
        contentView.addSubview(tagLabel)
        
        NSLayoutConstraint.activate([
            tagLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            tagLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            tagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            tagLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
        ])
    }
    
    // MARK: - Configuration
    func configure(with tag: Tag, isSelected: Bool = false) {
        tagLabel.text = "#\(tag.name)"
        self.tagId = tag.id
        self.isTagSelected = isSelected
    }
    
    // MARK: - Visual State Management
    private func updateVisualState() {
                
        DispatchQueue.main.async {
                self.contentView.backgroundColor = self.isTagSelected ?
                    Constants.Colors.tagSelectedBackground :
                    Constants.Colors.tagBackground
                
                self.tagLabel.textColor = self.isTagSelected ?
                    Constants.Colors.tagSelettedText :
                    Constants.Colors.tagText
        }
    }
    
    //MARK: TEMPORARY
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
//        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 32) // Fixed height
//        
//        // This will allow the width to adjust based on content while keeping fixed height
//        let size = contentView.systemLayoutSizeFitting(
//            targetSize,
//            withHorizontalFittingPriority: .fittingSizeLevel,
//            verticalFittingPriority: .required
//        )
//        
//        attributes.frame.size = size
//        return attributes
//    }
}
