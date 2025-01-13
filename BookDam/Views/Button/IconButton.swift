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
    
    init(title: String?, image: String?, action: Selector?, color: UIColor = Constants.Colors.accent ) {
        super.init(frame: .zero)
        
        if let title = title {
            self.setTitle(title, for: .normal)
            self.titleLabel?.font = Constants.Fonts.body
            self.setTitleColor(color, for: .normal)
            self.setTitleColor(color.withAlphaComponent(0.5), for: .highlighted)
            self.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if let image = image {
            let searchIcon = UIImage(systemName: image, withConfiguration: Constants.Configuration.icon)?.withRenderingMode(.alwaysTemplate)
            self.setImage(searchIcon, for: .normal)
            self.tintColor = color            
            self.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if let action = action {
            self.addTarget(self, action: action, for: .touchUpInside)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
