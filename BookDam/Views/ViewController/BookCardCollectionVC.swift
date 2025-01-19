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
    private var selectedIndexPaths = Set<IndexPath>()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.title
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(BookCardCell.self, forCellWithReuseIdentifier: BookCardCell.identifier)
        
        view.addSubview(countLabel)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.Layout.layoutMargin),
            countLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.layoutMargin),
        ])
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: Constants.Layout.layoutMargin),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.layoutMargin),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.layoutMargin),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
            selectedIndexPaths.forEach { indexPath in
                collectionView.deselectItem(at: indexPath, animated: true)
            }
            selectedIndexPaths.removeAll()
        } else {
            let allIndexPaths = (0..<books.count).map { IndexPath(item: $0, section: 0) }
                        
            allIndexPaths.forEach { indexPath in
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
            }
            selectedIndexPaths = Set(allIndexPaths)
        }
        
        collectionView.reloadData()
        
        updateParentAboutSelection()
    }
    
    func scrollToTop() {
        // Check if there are any items
        guard books.count > 0 else { return }
        
        // Create an index path for the first item
        let topIndexPath = IndexPath(item: 0, section: 0)
        
        // Scroll to top with animation
        collectionView.scrollToItem(at: topIndexPath, at: .top, animated: true)
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
                
        let interaction = UIContextMenuInteraction(delegate: self) // 삭제기능
        cell.addInteraction(interaction)
        
        return cell
    }
    
    func reloadData(with books: [Book]) {
        self.books = books
        selectedIndexPaths.removeAll()
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension BookCardCollectionVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let (cardWidth, cardHeight) = Constants.Size.calculateImageSize()
        
        return CGSize(width: cardWidth, height: cardHeight)
    }
}

// MARK: - UIContextMenuInteractionDelegate
extension BookCardCollectionVC: UIContextMenuInteractionDelegate {
    
    // Create context menu with delete action
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
//        let locationInCollectionView = collectionView.convert(location, from: collectionView.superview)
        let locationInCollectionView = interaction.location(in: collectionView.superview) // 위 둘 사이의 차이점??
        print(locationInCollectionView)
        
        // Get the index path for the item at the specified location
        guard let indexPath = collectionView.indexPathForItem(at: locationInCollectionView) else {
            print("No item at this location")
            return nil
        }
        
        // Retrieve the book corresponding to the index path
        let book = books[indexPath.row]
        print("Selected Book: \(book.title)") // For debugging
        
        // Create the delete action
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { _ in
            print("Deleting book: \(book.title)") // Perform the delete action here
            self.deleteBook(at: indexPath, book: book)

            // Call your delete function from CoreDataManager or similar
        }
        
        // Create and return the context menu
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(title: "", children: [deleteAction])
        }
    }

    // Function to delete the book from the array and collection view
    func deleteBook(at indexPath: IndexPath, book: Book) {
        // Remove from data source (array)
        books.remove(at: indexPath.row)
        
        // Remove from collection view
        collectionView.deleteItems(at: [indexPath])
        
        CoreDataManager.shared.deleteBookwithIsbn(by: book.isbn)
        
        reloadData(with: books)
        
        // Optionally delete from Core Data or your persistence layer
        // Example: CoreDataManager.shared.deleteBook(by: book.isbn)
        
        print("Deleted book: \(book.title)")
    }
}
