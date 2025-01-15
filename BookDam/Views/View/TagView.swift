//
//  TagView.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/15/25.
//

import Foundation
import UIKit

protocol TagViewDelegate: AnyObject {
    func tagViewDidSelect(_ tagView: TagView)
    func tagViewDidDeselect(_ tagView: TagView)
}

class TagView: UIView {
    
    // MARK: - Properties
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.smallBody
        label.textColor = UIColor.red
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    weak var delegate: TagViewDelegate?
    private(set) var isSelected: Bool = false
    private(set) var tagId: UUID
    
    // MARK: - Initialization
    init(tag: Tag) {
        self.tagId = tag.id
        super.init(frame: .zero)
        
        setupUI()
        configure(with: tag)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = Constants.Colors.tagBackground
        layer.cornerRadius = 15
        clipsToBounds = true
        
        addSubview(tagLabel)
        
        NSLayoutConstraint.activate([
            tagLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            tagLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            tagLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            tagLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    func configure(with tag: Tag) {
        tagLabel.text = "#\(tag.name)"
        updateSelectionState(isSelected)
    }
    
    func updateSelectionState(_ selected: Bool) {
        isSelected = selected
        
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = selected ? Constants.Colors.tagSelectedBackground : Constants.Colors.tagBackground
            self.tagLabel.textColor = selected ? Constants.Colors.tagSelettedText : Constants.Colors.tagText
            
            // Optional: Add a subtle border in unselected state for better visibility
            self.layer.borderWidth = selected ? 0 : 1
            self.layer.borderColor = selected ? nil : Constants.Colors.mainText.withAlphaComponent(0.3).cgColor
        }
    }
    
    // MARK: - Actions
    @objc private func handleTap() {
        updateSelectionState(!isSelected)
        if isSelected {
            delegate?.tagViewDidSelect(self)
        } else {
            delegate?.tagViewDidDeselect(self)
        }
    }
}
