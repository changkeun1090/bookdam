//
//  TagManagementVC.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/15/25.
//

import Foundation
import UIKit

protocol TagManagementSheetDelegate: AnyObject {
    func tagManagementSheet(_ sheet: TagManagementSheet, didUpdateSelectedTags tags: Set<UUID>)
    func tagManagementSheetDidSave(_ sheet: TagManagementSheet)
    func tagManagementSheetDidCancel(_ sheet: TagManagementSheet)
}

class TagManagementSheet: UIViewController {

    private var initialSelectedTagIds: Set<UUID>
    
    // MARK: - Properties
    weak var delegate: TagManagementSheetDelegate?
    private var selectedTagIds: Set<UUID>
//    private var tagViews: [TagView] = []
    private var tags: [Tag] = []

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Colors.mainBackground
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "태그 지정하기"
        label.font = Constants.Fonts.bodyBold
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 12
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCell.identifier)
        collectionView.allowsMultipleSelection = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = Constants.Colors.accent
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(Constants.Colors.subText, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("저장", for: .normal)
        button.setTitleColor(Constants.Colors.accent, for: .normal)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    init(selectedTagIds: Set<UUID> = []) {
        self.selectedTagIds = selectedTagIds
        // Store the initial selection for cancel functionality
        self.initialSelectedTagIds = selectedTagIds
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTags()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(collectionView)
        containerView.addSubview(addButton)
        containerView.addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(saveButton)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 300),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),
            
            addButton.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -16),
            addButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 44),
            addButton.widthAnchor.constraint(equalToConstant: 44),
            
            buttonStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Data Loading
    private func loadTags() {
        tags = TagManager.shared.tags
        
        // First, clear any existing selections
        collectionView.indexPathsForSelectedItems?.forEach { indexPath in
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        
        // Then reload the data
        collectionView.reloadData()
        
        // After reloading, we need to update all visible cells
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Update selection state for all tags
            for (index, tag) in self.tags.enumerated() {
                let indexPath = IndexPath(item: index, section: 0)
                
                if self.selectedTagIds.contains(tag.id) {
                    // Select in collection view
                    self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                    
                    // Update cell visual state
                    if let cell = self.collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell {
                        cell.isSelected = true
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        let alert = UIAlertController(title: "태그 추가", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "태그 이름을 입력하세요"
        }
        
        let addAction = UIAlertAction(title: "추가", style: .default) { [weak self] _ in
            guard let tagName = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !tagName.isEmpty else { return }
            
            TagManager.shared.createTag(name: tagName)
            self?.loadTags()
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        // Restore the original selection
        selectedTagIds = initialSelectedTagIds
        
        // Reload the selection state
        loadTags()
        
        // Notify delegate and dismiss
        delegate?.tagManagementSheetDidCancel(self)
        dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        delegate?.tagManagementSheetDidSave(self)
        dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension TagManagementSheet: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.identifier, for: indexPath) as? TagCollectionViewCell else {
            fatalError("Failed to dequeue TagCollectionViewCell")
        }
        
        let tag = tags[indexPath.item]
        cell.configure(with: tag)
        
        // Check if this tag was already selected (associated with the book)
        let isSelected = selectedTagIds.contains(tag.id)
        
        // Update cell's visual state
        cell.isSelected = isSelected
        
        return cell
    }
}


// MARK: - UICollectionViewDelegate
extension TagManagementSheet: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tagId = tags[indexPath.item].id
        selectedTagIds.insert(tagId)
        
        // Update cell visual state
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell {
            cell.isSelected = true
        }
        
        delegate?.tagManagementSheet(self, didUpdateSelectedTags: selectedTagIds)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let tagId = tags[indexPath.item].id
        selectedTagIds.remove(tagId)
        
        // Update cell visual state
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell {
            cell.isSelected = false
        }
        
        delegate?.tagManagementSheet(self, didUpdateSelectedTags: selectedTagIds)
    }
}

// MARK: - TagViewDelegate
extension TagManagementSheet: TagViewDelegate {
    func tagViewDidSelect(_ tagView: TagView) {
        selectedTagIds.insert(tagView.tagId)
        delegate?.tagManagementSheet(self, didUpdateSelectedTags: selectedTagIds)
    }
    
    func tagViewDidDeselect(_ tagView: TagView) {
        selectedTagIds.remove(tagView.tagId)
        delegate?.tagManagementSheet(self, didUpdateSelectedTags: selectedTagIds)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension TagManagementSheet: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return TagManagementPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

// TagManagementPresentationController.swift

class TagManagementPresentationController: UIPresentationController {
    
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.alpha = 0
        return view
    }()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        
        return CGRect(x: 0,
                     y: containerView.frame.height - 300,
                     width: containerView.frame.width,
                     height: 300)
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        dimmedView.frame = containerView.bounds
        containerView.addSubview(dimmedView)
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmedView.alpha = 1
            return
        }
        
        coordinator.animate { [weak self] _ in
            self?.dimmedView.alpha = 1
        }
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmedView.alpha = 0
            return
        }
        
        coordinator.animate { [weak self] _ in
            self?.dimmedView.alpha = 0
        }
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}
