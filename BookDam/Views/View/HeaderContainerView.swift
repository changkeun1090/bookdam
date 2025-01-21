//
//  File.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/21/25.
//

import Foundation
import UIKit

protocol HeaderContainerViewDelegate: AnyObject {
    func headerContainer(_ view: HeaderContainerView, didDeselectTag tagId: UUID)
    func headerContainerDidClearAllTags(_ view: HeaderContainerView)
}

class HeaderContainerView: UIView {
    
    // MARK: - Properties
    weak var delegate: HeaderContainerViewDelegate?
    private var appliedTags: [Tag] = []
    
    // MARK: - UI Components
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.title
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tagsContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var tagsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCell.identifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Add subviews
        addSubview(countLabel)
        addSubview(tagsContainerView)
        
        tagsContainerView.addSubview(tagsCollectionView)
        
        NSLayoutConstraint.activate([
            // Container height
            heightAnchor.constraint(equalToConstant: 32),
            
            // Count label constraints
            countLabel.topAnchor.constraint(equalTo: topAnchor),
            countLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            countLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Tags container view
            tagsContainerView.topAnchor.constraint(equalTo: topAnchor),
            tagsContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tagsContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tagsContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Tags collection view
            tagsCollectionView.leadingAnchor.constraint(equalTo: tagsContainerView.trailingAnchor),
            tagsCollectionView.trailingAnchor.constraint(equalTo: tagsContainerView.trailingAnchor),
            tagsCollectionView.topAnchor.constraint(equalTo: tagsContainerView.topAnchor),
            tagsCollectionView.bottomAnchor.constraint(equalTo: tagsContainerView.bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    func updateCount(_ count: Int) {
        let formattedCount = String(format: "총 %d권", count)
        countLabel.text = formattedCount
    }
    
    func showFilterMode(with tags: [Tag]) {
        UIView.animate(withDuration: 0.3) {
            self.countLabel.isHidden = true
            self.tagsContainerView.isHidden = false
        }
        self.appliedTags = tags
        tagsCollectionView.reloadData()
    }
    
    func showNormalMode() {
        UIView.animate(withDuration: 0.3) {
            self.countLabel.isHidden = false
            self.tagsContainerView.isHidden = true
        }
        self.appliedTags = []
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        delegate?.headerContainerDidClearAllTags(self)
    }
}

// MARK: - UICollectionViewDataSource
extension HeaderContainerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appliedTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.identifier, for: indexPath) as? TagCollectionViewCell else {
            fatalError("Unable to dequeue TagCollectionViewCell")
        }
        
        let tag = appliedTags[indexPath.item]
        cell.configure(with: tag, isTagSelected: true)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension HeaderContainerView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tag = appliedTags[indexPath.item]
        delegate?.headerContainer(self, didDeselectTag: tag.id)
    }
}
