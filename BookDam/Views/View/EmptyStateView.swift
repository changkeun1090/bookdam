//
//  EmptyStateView.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/24/25.
//

import Foundation
import UIKit

class EmptyStateView: UIView {
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.Layout.mdMargin
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Constants.Colors.subText
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = Constants.Fonts.body
        label.textColor = Constants.Colors.subText
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(stackView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Layout.layoutMargin),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Layout.layoutMargin),
            
            imageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func configure(image: UIImage?, message: String) {
        imageView.image = image
        messageLabel.text = message
    }
}
