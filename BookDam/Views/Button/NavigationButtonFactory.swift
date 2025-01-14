//
//  NavigationButton.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/14/25.
//

import UIKit

class NavigationButtonFactory {
    
    // MARK: - Navigation Title Configuration
      static func configureTitleView(
          for viewController: UIViewController,
          title: String,
          subtitle: String? = nil
      ) {
          if let subtitle = subtitle {
              // Create container for title and subtitle
              let titleView = UIView()
              
              // Create and configure title label
              let titleLabel = UILabel()
              titleLabel.text = title
              titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
              titleLabel.textAlignment = .center
              
              // Create and configure subtitle label
              let subtitleLabel = UILabel()
              subtitleLabel.text = subtitle
              subtitleLabel.font = .systemFont(ofSize: 12)
              subtitleLabel.textAlignment = .center
              subtitleLabel.textColor = .secondaryLabel
              
              // Create stack view to hold labels
              let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
              stackView.axis = .vertical
              stackView.alignment = .center
              stackView.spacing = 2
              
              // Add stack view to title view
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
              // Simple title without subtitle
              viewController.navigationItem.title = title
          }
      }
      
    
    enum ButtonStyle {
        case plain
        case warning
        case accent
        
        var color: UIColor {
            switch self {
            case .plain:
                return .systemBlue
            case .warning:
                return Constants.Colors.warning
            case .accent:
                return Constants.Colors.accent
            }
        }
    }
    
    static func createTextButton(
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
    
    static func createImageButton(
        image: String,
        style: ButtonStyle = .plain,
        isEnabled: Bool = true,
        target: Any?,
        action: Selector?
    ) -> UIBarButtonItem {
        let button = UIBarButtonItem(
            image: UIImage(systemName: image),
            style: .plain,
            target: target,
            action: action
        )
        button.tintColor = style.color
        button.isEnabled = isEnabled
        return button
    }
    
    static func createMenuButton(
        image: String,
        menu: UIMenu,
        style: ButtonStyle = .plain,
        isEnabled: Bool = true
    ) -> UIBarButtonItem {
        let button = UIBarButtonItem(
            image: UIImage(systemName: image),
            menu: menu
        )
        button.tintColor = style.color
        button.isEnabled = isEnabled
        return button
    }
}
