//
//  AppliedTagsView.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/21/25.
//

import Foundation
import UIKit

protocol AppliedTagsViewDelegate: AnyObject {
    func appliedTagsView(_ view: AppliedTagsView, didDeselectTag tagId: UUID)
    func appliedTagsViewDidClearAll(_ view: AppliedTagsView)
}

class AppliedTagsView: UIView {
    
    // MARK: - Properties
    weak var delegate: AppliedTagsViewDelegate?
    private var appliedTags: [Tag] = []
    
    // MARK: - UI Components
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 60, height: 32)
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
    
    // MARK: - UI Setup
    private func setupUI() {
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    func configure(with tags: [Tag]) {
        self.appliedTags = tags
        collectionView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        delegate?.appliedTagsViewDidClearAll(self)
    }
}

// MARK: - UICollectionViewDataSource
extension AppliedTagsView: UICollectionViewDataSource {
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
extension AppliedTagsView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tag = appliedTags[indexPath.item]
        delegate?.appliedTagsView(self, didDeselectTag: tag.id)
    }
}
