//
//  TagManagementVC.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/15/25.
//

import Foundation
import UIKit

class TagManagementSheet: UIViewController, TagSelectionVC {
    
    let tagManager = TagManager.shared
    weak var delegate: TagSelectionVCDelegate?
    private var initialSelectedTagIds: Set<UUID>
    var selectedTagIds: Set<UUID>
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
            
            let result = self?.tagManager.createTag(name: tagName)
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
                
            case .duplicateExists:
                DispatchQueue.main.async {
                    self?.showDuplicateTagAlert(tagName: tagName)
                }
                
            case .invalid:
                DispatchQueue.main.async {
                    self?.showAlert(title: "오류", message: "유효하지 않은 태그명입니다")
                }
            case .none:
                return
            }
        }
        
        addAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "취소", style: .default)
        
        addAction.setValue(Constants.Colors.accent, forKey: "titleTextColor")
        cancelAction.setValue(Constants.Colors.warning, forKey: "titleTextColor")
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        
        if let textField = alert.textFields?.first {
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
        delegate?.tagSelectionVCDidCancel(self)
        dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        delegate?.tagSelectionVC(self, didUpdateSelectedTags: selectedTagIds)
        delegate?.tagSelectionVCDidSave(self)
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
        let tagId = tags[indexPath.item].id
        selectedTagIds.insert(tagId)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell {
            cell.isTagSelected = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
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

// MARK: - Tag Alert
extension TagManagementSheet {
    private func showDuplicateTagAlert(tagName: String) {
        let alert = UIAlertController(
            title: "중복된 태그",
            message: "'\(tagName)' 태그가 이미 존재합니다",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "확인", style: .default)
        okAction.setValue(Constants.Colors.accent, forKey: "titleTextColor")
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "확인", style: .default)
        okAction.setValue(Constants.Colors.accent, forKey: "titleTextColor")
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}
