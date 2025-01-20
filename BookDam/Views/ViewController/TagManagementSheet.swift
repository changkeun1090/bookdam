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

    let tagManager = TagManager.shared
    weak var delegate: TagManagementSheetDelegate?
    
    private var initialSelectedTagIds: Set<UUID>
    private var selectedTagIds: Set<UUID>
    
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
        label.text = "태그 지정하기(선택)"
        label.font = Constants.Fonts.bodyBold
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = LeftAlignedFlowLayout()
        layout.minimumInteritemSpacing = Constants.Layout.smMargin
        layout.minimumLineSpacing = Constants.Layout.mdMargin
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
        ButtonFactory.createImageButton(image: Constants.Icons.addTag, size: .large, target: self, action: #selector(addIconTapped))
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var saveButton: UIButton = {
        ButtonFactory.createTextButton(title: "저장", style: .accent, target: self, action: #selector(saveButtonTapped))
    }()
    
    
    private lazy var cancelButton: UIButton = {
        ButtonFactory.createTextButton(title: "취소", target: self, action: #selector(cancelButtonTapped))
    }()
    
    
    // MARK: - Initialization
    init(selectedTagIds: Set<UUID> = []) {
        self.selectedTagIds = selectedTagIds
        self.initialSelectedTagIds = selectedTagIds
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTags()
        configureSheet()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = Constants.Colors.subBackground
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(collectionView)
        containerView.addSubview(addButton)
        containerView.addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(saveButton)
        
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
            collectionView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -Constants.Layout.layoutMargin),
            
            addButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: Constants.Layout.layoutMargin),
            addButton.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -Constants.Layout.layoutMargin),
            addButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            buttonStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.Layout.layoutMargin),
            buttonStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.Layout.layoutMargin),
            buttonStackView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Layout.layoutMargin),
//            buttonStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configureSheet() {
        modalPresentationStyle = .pageSheet
        
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 12
//            sheet.prefersScrollingExpandsWhenScrolled = true
            sheet.prefersEdgeAttachedInCompactHeight = true
        }
    }
    
    // MARK: - Data Loading
    private func loadTags() {
        tagManager.delegate = self
        tagManager.loadTags()
    }
 
    // MARK: - Actions
    
    @objc private func addIconTapped() {
        let alert = UIAlertController(title: "태그 추가", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "추가할 태그를 입력하세요"
        }
        
        let addAction = UIAlertAction(title: "추가", style: .default) { [weak self] _ in
            guard let tagName = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !tagName.isEmpty else { return }
            
            self?.tagManager.createTag(name: tagName)
                        
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        addAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "취소", style: .default)
        
        addAction.setValue(Constants.Colors.accent, forKey: "titleTextColor")
        cancelAction.setValue(Constants.Colors.warning, forKey: "titleTextColor")
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        
        if let textField = alert.textFields?.first {
            textField.delegate = self
            textField.addAction(UIAction { _ in
                if let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !text.isEmpty {
                    addAction.isEnabled = true
                } else {
                    addAction.isEnabled = false
                }
            }, for: .editingChanged)
        }
        
        present(alert, animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        selectedTagIds = initialSelectedTagIds
        
        loadTags()
        
        delegate?.tagManagementSheetDidCancel(self)
        dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        delegate?.tagManagementSheet(self, didUpdateSelectedTags: selectedTagIds)
        delegate?.tagManagementSheetDidSave(self)
//        dismiss(animated: true)
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
        let isTagSelected = selectedTagIds.contains(tag.id)
        
        cell.configure(with: tag, isTagSelected: isTagSelected)
        
        if isTagSelected {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
                    
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension TagManagementSheet: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("SELECT!!!!!")
        
        let tagId = tags[indexPath.item].id
        selectedTagIds.insert(tagId)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell {
            cell.isTagSelected = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("DESELECT-----")
        let tagId = tags[indexPath.item].id
        selectedTagIds.remove(tagId)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell {
            cell.isTagSelected = false
        }
    }
}

extension TagManagementSheet: TagManagerDelegate {
    func tagManager(_ manager: TagManager, didUpdateTags tags: [Tag]) {
        self.tags = tags
    }
    
    func tagManager(_ manager: TagManager, didDeleteTags ids: Set<UUID>) {
    }
}

// MARK: - UITextFieldDelegate
extension TagManagementSheet: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           !text.isEmpty {
            TagManager.shared.createTag(name: text)
            loadTags()
            dismiss(animated: true)
        }
        return true
    }
}

