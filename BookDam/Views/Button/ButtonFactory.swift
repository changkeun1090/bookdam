//
//  ButtonFactory.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/16/25.
//

import Foundation
import UIKit

class ButtonFactory {
    // MARK: - Types
    enum ButtonStyle {
        case plain
        case warning
        case accent
        
        var color: UIColor {
            switch self {
            case .plain:
                return Constants.Colors.subText                
            case .warning:
                return Constants.Colors.warning
            case .accent:
                return Constants.Colors.accent
            }
        }
    }
    
    enum ButtonSize {
        case small
        case medium
        case large
        case custom(CGFloat)
        
        var pointSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 16
            case .large: return 24
            case .custom(let size): return size
            }
        }
    }
    
    // MARK: - Navigation Button Creation
    static func createNavTextButton(
        title: String,
        style: ButtonStyle = .plain,
        isEnabled: Bool = true,
        target: Any?,
        action: Selector?
    ) -> UIBarButtonItem {
        let button = UIBarButtonItem(
            title: title,
            style: .plain,
            target: target,
            action: action
        )
        button.tintColor = style.color
        button.isEnabled = isEnabled
        return button
    }
    
    static func createNavImageButton(
        image: String,
        style: ButtonStyle = .plain,
        size: ButtonSize = .medium,
        isEnabled: Bool = true,
        target: Any?,
        action: Selector?
    ) -> UIBarButtonItem {
        let configuration = UIImage.SymbolConfiguration(pointSize: size.pointSize)
        let image = UIImage(systemName: image, withConfiguration: configuration)
        
        let button = UIBarButtonItem(
            image: image,
            style: .plain,
            target: target,
            action: action
        )
        button.tintColor = style.color
        button.isEnabled = isEnabled
        return button
    }
    
    static func createNavMenuButton(
        image: String,
        menu: UIMenu,
        style: ButtonStyle = .plain,
        size: ButtonSize = .medium,
        isEnabled: Bool = true
    ) -> UIBarButtonItem {
        let configuration = UIImage.SymbolConfiguration(pointSize: size.pointSize)
        let image = UIImage(systemName: image, withConfiguration: configuration)
        
        let button = UIBarButtonItem(
            image: image,
            menu: menu
        )
        button.tintColor = style.color
        button.isEnabled = isEnabled
        return button
    }
    
    // MARK: - Regular Button Creation
    static func createTextButton(
        title: String,
        style: ButtonStyle = .plain,
        isEnabled: Bool = true,
        translatesAutoresizingMaskIntoConstraints: Bool = false,
        target: Any? = nil,
        action: Selector? = nil
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.tintColor = style.color
        button.isEnabled = isEnabled
        button.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints

        if let target = target, let action = action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
                
        return button
    }
    
    static func createImageButton(
        image: String,
        style: ButtonStyle = .plain,
        size: ButtonSize = .medium,
        isEnabled: Bool = true,
        translatesAutoresizingMaskIntoConstraints: Bool = false,
        target: Any? = nil,
        action: Selector? = nil
    ) -> UIButton {
        let button = UIButton(type: .system)
        
        let configuration = UIImage.SymbolConfiguration(pointSize: size.pointSize)
        let image = UIImage(systemName: image, withConfiguration: configuration)
        button.setImage(image, for: .normal)
        
        button.tintColor = style.color
        button.isEnabled = isEnabled
        button.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints

        if let target = target, let action = action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        
        return button
    }
    
    // MARK: - Tab Bar Item Creation
    static func createTabBarItem(
        title: String,
        image: String,
        selectedImage: String? = nil,
        size: ButtonSize = .medium
    ) -> UITabBarItem {
        let configuration = UIImage.SymbolConfiguration(pointSize: size.pointSize)
        let image = UIImage(systemName: image, withConfiguration: configuration)
        let selectedImage = selectedImage.flatMap { UIImage(systemName: $0, withConfiguration: configuration) }
        
        return UITabBarItem(
            title: title,
            image: image,
            selectedImage: selectedImage
        )
    }
    
    // MARK: - Navigation Title Configuration
    static func configureTitleView(
        for viewController: UIViewController,
        title: String,
        subtitle: String? = nil
    ) {
        if let subtitle = subtitle {
            let titleView = UIView()
            
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
            titleLabel.textAlignment = .center
            
            let subtitleLabel = UILabel()
            subtitleLabel.text = subtitle
            subtitleLabel.font = .systemFont(ofSize: 12)
            subtitleLabel.textAlignment = .center
            subtitleLabel.textColor = .secondaryLabel
            
            let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 2
            
            titleView.addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: titleView.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
                stackView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor)
            ])
            
            viewController.navigationItem.titleView = titleView
        } else {
            viewController.navigationItem.title = title
        }
    }
}
