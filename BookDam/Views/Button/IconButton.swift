//
//  BDIconButton.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/5/25.
//

import UIKit

class IconButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(title: String?, image: String?, action: Selector?) {
        super.init(frame: .zero)
        
        if let title = title {
            self.setTitle(title, for: .normal)
            self.titleLabel?.font = Constants.Fonts.largeBody
            self.setTitleColor(Constants.Colors.accent, for: .normal)
            self.setTitleColor(Constants.Colors.accent.withAlphaComponent(0.5), for: .highlighted)
            self.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if let image = image {
            let searchIcon = UIImage(systemName: image, withConfiguration: Constants.Configuration.icon)?.withRenderingMode(.alwaysTemplate)
            self.setImage(searchIcon, for: .normal)
            self.tintColor = Constants.Colors.accent
            self.alpha = 1.0
            self.addTarget(self, action: #selector(handleTouchDown(_:)), for: .touchDown)
            self.addTarget(self, action: #selector(handleTouchUp(_:)), for: .touchUpInside)
            self.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if let action = action {
            self.addTarget(self, action: action, for: .touchUpInside)
        }
        
        
    }
    
    @objc private func handleTouchDown(_ sender: UIButton) {
        sender.alpha = 0.5
    }

    @objc private func handleTouchUp(_ sender: UIButton) {
        sender.alpha = 1.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
