//
//  BookCardCollectionVC.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/3/25.
//

import UIKit

class BookCardCollectionVC: UIViewController {
    
    private var collectionView: UICollectionView!
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var isSelectMode = false
    private var isFilterMode = false
    
    private var selectedIndexPaths = Set<IndexPath>()
    private var appliedTags: Set<UUID> = []
    
    private let headerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.title
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var appliedTagsView: AppliedTagsView = {
        let view = AppliedTagsView()
        view.isHidden = true
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var books: [Book] = [] {
        didSet {
            updateCountLabel()
        }
    }
        
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = Constants.Colors.mainBackground
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = Constants.Layout.gutter
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(BookCardCell.self, forCellWithReuseIdentifier: BookCardCell.identifier)
        
        view.addSubview(headerContainer)
        headerContainer.addSubview(countLabel)
        headerContainer.addSubview(appliedTagsView)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.layoutMargin),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.layoutMargin),
            headerContainer.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            // Add constraints for countLabel
            countLabel.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            countLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            countLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            countLabel.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            
            // Add constraints for appliedTagsView
            appliedTagsView.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            appliedTagsView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            appliedTagsView.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            appliedTagsView.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            
        ])
  
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: Constants.Layout.layoutMargin),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.layoutMargin),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.layoutMargin),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func reloadData(with books: [Book], appliedTags: Set<UUID> = []) {
        
        self.books = books
        self.appliedTags = appliedTags
        
        if !appliedTags.isEmpty {
            let tags = TagManager.shared.tags.filter { appliedTags.contains($0.id) }
            enterFilterMode(with: tags)
        } else if isFilterMode {
            exitFilterMode()
        }
        
        selectedIndexPaths.removeAll()
        collectionView.reloadData()
        
    }
    
    private func updateCountLabel() {
        let formattedCount = String(format: "총 %d권", books.count)
        countLabel.text = formattedCount
    }
    
    func enterSelectMode() {
        isSelectMode = true
        countLabel.isHidden = true
        selectedIndexPaths.removeAll()
        collectionView.allowsMultipleSelection = true
        collectionView.reloadData()
    }
    
    func exitSelectMode() {
        isSelectMode = false
        countLabel.isHidden = false
        collectionView.allowsMultipleSelection = false
        collectionView.reloadData()
        selectedIndexPaths.removeAll()
    }
        
    func toggleSelectAll() {
        guard isSelectMode else { return }
                
        let allSelected = selectedIndexPaths.count == books.count
        
        if allSelected {
            selectedIndexPaths.removeAll()
        } else {
            let allIndexPaths = (0..<books.count).map { IndexPath(item: $0, section: 0) }
            selectedIndexPaths = Set(allIndexPaths)
        }
        
        collectionView.reloadData()
        
        updateParentAboutSelection()
    }
    
    func scrollToTop() {
        guard books.count > 0 else { return }
        
        let topIndexPath = IndexPath(item: 0, section: 0)
        
        collectionView.scrollToItem(at: topIndexPath, at: .top, animated: true)
    }
    
    func enterFilterMode(with tags: [Tag]) {
        isFilterMode = true
        countLabel.isHidden = true
        appliedTagsView.isHidden = false
        appliedTagsView.configure(with: tags)
    }

    func exitFilterMode() {
        isFilterMode = false
        countLabel.isHidden = false
        appliedTagsView.isHidden = true
        appliedTags.removeAll()
        if let parent = parent as? BooksVC {
            parent.tagSelectionVC(parent, didUpdateSelectedTags: [])
        }
    }
}

// MARK: - UICollectionViewDelegate
extension BookCardCollectionVC: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isSelectMode {
            
            let isSelected = selectedIndexPaths.contains(indexPath)
            
            if let cell = collectionView.cellForItem(at: indexPath) as? BookCardCell {
                cell.updateSelectionState(!isSelected)
            }
            
            if isSelected {
                selectedIndexPaths.remove(indexPath)
            } else {
                selectedIndexPaths.insert(indexPath)
            }
            
            updateParentAboutSelection()
            
        } else {
            
            let selectedBook = books[indexPath.row]
            let bookDetailVC = BookDetailVC()
            bookDetailVC.configure(with: selectedBook, isSaved: true)
            bookDetailVC.hidesBottomBarWhenPushed = true
            bookDetailVC.deletionDelegate = self.parent as? BooksDeletionDelegate
            
            navigationController?.pushViewController(bookDetailVC, animated: true)        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if isSelectMode {
                        
            let isSelected = selectedIndexPaths.contains(indexPath)
            
            if let cell = collectionView.cellForItem(at: indexPath) as? BookCardCell {
                cell.updateSelectionState(!isSelected)
            }
            
            if isSelected {
                selectedIndexPaths.remove(indexPath)
            } else {
                selectedIndexPaths.insert(indexPath)
            }
                     
            updateParentAboutSelection()
        }
    }
    
    private func updateParentAboutSelection() {
        if let parentVC = parent as? BooksVC {
            let selectedBooks = selectedIndexPaths.map { books[$0.row].isbn }
            parentVC.updateSelectedBooks(selectedBooks)
        }
    }
}

// MARK: - UICollectionView DataSource
extension BookCardCollectionVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookCardCell.identifier, for: indexPath) as? BookCardCell else {
            fatalError("Unable to dequeue BookCardCell")
        }
        
        let book = books[indexPath.row]
        cell.configure(with: book)
        
        if isSelectMode {
            cell.showSelectionIndicator(selected: selectedIndexPaths.contains(indexPath))
        } else {
            cell.hideSelectionIndicator()
        }
        
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension BookCardCollectionVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let (cardWidth, cardHeight) = Constants.Size.calculateImageSize()
        
        return CGSize(width: cardWidth, height: cardHeight)
    }
}

// MARK: - AppliedTagsViewDelegate
extension BookCardCollectionVC: AppliedTagsViewDelegate {
    func appliedTagsView(_ view: AppliedTagsView, didDeselectTag tagId: UUID) {
        appliedTags.remove(tagId)
        if let parent = parent as? BooksVC {
            parent.tagSelectionVC(parent, didUpdateSelectedTags: appliedTags)
        }
    }
    
    func appliedTagsViewDidClearAll(_ view: AppliedTagsView) {
        exitFilterMode()
    }
}
