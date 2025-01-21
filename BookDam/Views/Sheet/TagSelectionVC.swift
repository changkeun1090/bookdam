//
//  TagSelectionVC.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/21/25.
//

import Foundation
import UIKit

protocol TagSelectionVCDelegate: AnyObject {
    func tagSelectionVC(_ controller: UIViewController, didUpdateSelectedTags tags: Set<UUID>)
    func tagSelectionVCDidSave(_ sheet: TagManagementSheet)
    func tagSelectionVCDidCancel(_ sheet: TagManagementSheet)
}

protocol TagSelectionVC: UIViewController {
    // Properties
    var selectedTagIds: Set<UUID> { get set }
    var tagManager: TagManager { get }
    var collectionView: UICollectionView { get }
    var delegate: TagSelectionVCDelegate? { get set }
    
    // Setup methods
    func setupBaseUI()
    func configureSheet()
    func createCollectionViewLayout() -> UICollectionViewLayout

}

extension TagSelectionVC {
    func setupBaseUI() {
        view.backgroundColor = Constants.Colors.subBackground
        
        let containerView = UIView()
        containerView.backgroundColor = Constants.Colors.mainBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = LeftAlignedFlowLayout()
        layout.minimumInteritemSpacing = Constants.Layout.smMargin
        layout.minimumLineSpacing = Constants.Layout.mdMargin
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return layout
    }
    
    func configureSheet() {
        modalPresentationStyle = .pageSheet
        
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 12
            sheet.prefersEdgeAttachedInCompactHeight = true
        }
    }
}
