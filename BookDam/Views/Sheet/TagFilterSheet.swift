//
//  TagFilteringSheet.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/21/25.
//

import Foundation
import UIKit

class TagFilterSheet: UIViewController, TagSelectionVC {
        
    let tagManager = TagManager.shared
    weak var delegate: TagSelectionVCDelegate?
     
    var selectedTagIds: Set<UUID>
    private var tags: [Tag] = []
    
    // MARK: - UI Components
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
        label.text = "태그로 책 찾기"
        label.font = Constants.Fonts.bodyBold
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCell.identifier)
        cv.allowsMultipleSelection = true
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var applyButton: UIButton = {
        ButtonFactory.createTextButton(
            title: "적용",
            style: .accent,
            target: self,
            action: #selector(applyButtonTapped)
        )
    }()
    
    private lazy var deselectButton: UIButton = {
        let button = ButtonFactory.createTextButton(
            title: "전체 해제",
            style: .warning,
            target: self,
            action: #selector(deselectButtonTapped)
        )
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Initialization
    init(selectedTagIds: Set<UUID> = []) {
        self.selectedTagIds = selectedTagIds
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBaseUI()
//        setupCollectionView()
        configureSheet()
        setupConstraints()
        loadTags()
        updateDeselectButton()
    }
    
    // MARK: - Setup
    private func setupConstraints() {
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(collectionView)
        containerView.addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(deselectButton)
        buttonStackView.addArrangedSubview(applyButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.Layout.layoutMargin),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.Layout.layoutMargin),
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.Layout.layoutMargin),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.Layout.layoutMargin),
            collectionView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -Constants.Layout.layoutMargin),
            
            buttonStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.Layout.layoutMargin),
            buttonStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.Layout.layoutMargin),
            buttonStackView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Layout.layoutMargin)
        ])
    }
    
    // MARK: - Data Loading
    private func loadTags() {
        tagManager.delegate = self
        tagManager.loadTags()
    }
    
    // MARK: - UI Updates
    private func updateDeselectButton() {
        deselectButton.isEnabled = !selectedTagIds.isEmpty
    }
    
    // MARK: - Actions
    @objc private func applyButtonTapped() {
        delegate?.tagSelectionVC(self, didUpdateSelectedTags: selectedTagIds)
        dismiss(animated: true)
    }
    
    @objc private func deselectButtonTapped() {
        selectedTagIds.removeAll()
        collectionView.reloadData()
        updateDeselectButton()
    }
}

// MARK: - UICollectionViewDataSource
extension TagFilterSheet: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.identifier, for: indexPath) as? TagCollectionViewCell else {
            fatalError("Failed to dequeue TagCollectionViewCell")
        }
        
        let tag = tags[indexPath.item]
        let isTagSelected = selectedTagIds.contains(tag.id)
        
        cell.configure(with: tag, isTagSelected: isTagSelected)
        
        if isTagSelected {
            cell.isSelected = true
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension TagFilterSheet: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tagId = tags[indexPath.item].id
        selectedTagIds.insert(tagId)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell {
            cell.isTagSelected = true
        }
        
        updateDeselectButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let tagId = tags[indexPath.item].id
        selectedTagIds.remove(tagId)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell {
            cell.isTagSelected = false
        }
        
        updateDeselectButton()
    }
}

// MARK: - TagManagerDelegate
extension TagFilterSheet: TagManagerDelegate {
    func tagManager(_ manager: TagManager, didUpdateTags tags: [Tag]) {
        self.tags = tags
        collectionView.reloadData()
    }
    
    func tagManager(_ manager: TagManager, didDeleteTags ids: Set<UUID>) {
    }
}
