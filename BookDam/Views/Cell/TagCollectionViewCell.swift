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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Selection State
    override var isSelected: Bool {
        didSet {
            // Only handle visual updates here, don't call other methods
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
            tagLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    func configure(with tag: Tag) {
        tagLabel.text = "#\(tag.name)"
        self.tagId = tag.id
    }
    
    // MARK: - Visual State Management
    private func updateVisualState() {
        UIView.animate(withDuration: 0.2) {
            self.contentView.backgroundColor = self.isSelected ?
                Constants.Colors.tagSelectedBackground :
                Constants.Colors.tagBackground
            
            self.tagLabel.textColor = self.isSelected ?
                Constants.Colors.tagSelettedText :
                Constants.Colors.tagText
        }
    }
}
