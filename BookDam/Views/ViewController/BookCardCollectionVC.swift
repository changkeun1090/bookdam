//
//  BookCardCollectionVC.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/3/25.
//

import UIKit

class BookCardCollectionVC: UIViewController {
    
    // MARK: - Properties
    private var collectionView: UICollectionView!
    private let searchController = UISearchController(searchResultsController: nil)
    
    var books:[Book] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = Constants.Colors.mainBackground
        
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: Constants.Layout.layoutMargin, bottom: Constants.Layout.layoutMargin, right: Constants.Layout.layoutMargin)
        layout.minimumLineSpacing = Constants.Layout.gutter
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(BookCardCell.self, forCellWithReuseIdentifier: BookCardCell.identifier)
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UICollectionViewDelegate
extension BookCardCollectionVC: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedBook = books[indexPath.row]        
        let bookDetailVC = BookDetailVC()
        
        bookDetailVC.configure(with: selectedBook, isSaved: true)
        bookDetailVC.hidesBottomBarWhenPushed = true
        bookDetailVC.deletionDelegate = self.parent as? BooksDeletionDelegate
        
        navigationController?.pushViewController(bookDetailVC, animated: true)
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
        
        // Add context menu interaction to each cell
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.addInteraction(interaction)
        
        return cell
    }
    
    func reloadData(with books: [Book]) {
        self.books = books
        collectionView.reloadData() // Reload the collection view with the new data
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

