//
//  BooksVC.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/3/25.
//

import UIKit
import CoreData

protocol BooksDeletionDelegate: AnyObject {
    func didDeleteBook(withIsbn isbn: String)
}

class BooksVC: UIViewController {
    
    private let bookCardCollectionVC = BookCardCollectionVC()
    private var searchController: UISearchController!
    
    private var books:[Book] = []
    private var filteredBooks: [Book] = []
    
    private var searchTimer: Timer?
    
    private var isSearching = false
    private var collectionViewTopConstraint: NSLayoutConstraint!
    private var horizontalStackViewHeightConstraint: NSLayoutConstraint!
    
    private let tagButton = IconButton(title: "태그", image: nil, action: nil)
    private let moreButton = IconButton(title: nil, image: Constants.Icons.more, action: nil)
    private let searchButton = IconButton(title: nil, image: Constants.Icons.search, action: nil)
    
    private lazy var rightStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [searchButton, moreButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = Constants.Layout.mdMargin
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [tagButton, rightStackView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        // stackView와 content 사이의 space 설정
        stackView.layoutMargins = UIEdgeInsets(top: Constants.Layout.layoutMargin,
                                               left: Constants.Layout.layoutMargin,
                                               bottom: 0,
                                               right: Constants.Layout.layoutMargin)
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.Colors.mainBackground
        setupSearchController()
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isSearching {
             navigationController?.setNavigationBarHidden(true, animated: false)
             // Only fetch and reload books if we're not searching
             fetchAllBooks()
             bookCardCollectionVC.reloadData(with: books)
         }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        
        view.addSubview(horizontalStackView)
        
        horizontalStackViewHeightConstraint = horizontalStackView.heightAnchor.constraint(equalToConstant: 30)

        NSLayoutConstraint.activate([
            horizontalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            horizontalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Layout.layoutMargin),
            horizontalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.layoutMargin),
            horizontalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.layoutMargin),
            horizontalStackViewHeightConstraint
        ])
        
        addChild(bookCardCollectionVC)
        view.addSubview(bookCardCollectionVC.view)
        
        bookCardCollectionVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        collectionViewTopConstraint = bookCardCollectionVC.view.topAnchor.constraint(equalTo: horizontalStackView.bottomAnchor, constant: Constants.Layout.layoutMargin)
        
        NSLayoutConstraint.activate([
            collectionViewTopConstraint,
            bookCardCollectionVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bookCardCollectionVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bookCardCollectionVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        bookCardCollectionVC.didMove(toParent: self)
    }
    
    // MARK: - Search Setup
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "저장된 책의 제목을 입력해주세요"
        
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = Constants.Colors.accent
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchButton.addTarget(self, action: #selector(showSearchBar), for: .touchUpInside)
    }
        
    @objc private func showSearchBar() {
        isSearching = true  // Set this first
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        searchController.isActive = true
        searchController.searchBar.becomeFirstResponder()
        
        updateLayoutForSearchState()
        
        bookCardCollectionVC.reloadData(with: [])
        
    }
    
    private func updateLayoutForSearchState() {
        if isSearching {
            horizontalStackView.isHidden = true
            horizontalStackViewHeightConstraint.constant = 0
            collectionViewTopConstraint.constant = 0
        } else {
            horizontalStackView.isHidden = false
            horizontalStackViewHeightConstraint.constant = 30
            collectionViewTopConstraint.constant = Constants.Layout.layoutMargin
        }
                
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
     
    func fetchAllBooks() {
        if let bookEntities = CoreDataManager.shared.fetchBooks() {
            self.books = bookEntities.map { bookEntity in
                return Book(
                    title: bookEntity.title ?? "",
                    author: bookEntity.author ?? "",
                    isbn: bookEntity.isbn ?? "",
                    publisher: bookEntity.publisher ?? "",
                    cover: bookEntity.cover,
                    pubDate: bookEntity.pubDate,
                    bookDescription: bookEntity.bookDescription,
                    link: bookEntity.link
                )
            }
        } else {
            print("Failed to fetch books from Core Data")
        }
    }
    
    func resetSearchState() {
        isSearching = false
        searchController.isActive = false
        updateLayoutForSearchState()
        navigationController?.setNavigationBarHidden(true, animated: false)
        fetchAllBooks()
        bookCardCollectionVC.reloadData(with: books)
    }
}

extension BooksVC: BooksDeletionDelegate {
    func didDeleteBook(withIsbn isbn: String) {
        // Remove the book from both arrays
        books.removeAll { $0.isbn == isbn }
        filteredBooks.removeAll { $0.isbn == isbn }
        
        if isSearching {
            // If searching, update with current filtered results
            bookCardCollectionVC.reloadData(with: filteredBooks)
        } else {
            // If not searching, update with all books
            bookCardCollectionVC.reloadData(with: books)
        }
    }
}

extension BooksVC:UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        // Cancel any previous timer
        searchTimer?.invalidate()
        
        // Create a new timer that will fire after 0.5 seconds
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let self = self, self.isSearching else { return }
            
            guard let searchText = searchController.searchBar.text?.lowercased(), !searchText.isEmpty else {
                self.bookCardCollectionVC.reloadData(with: [])
                return
            }
            
            self.filteredBooks = self.books.filter { book in
                book.title.lowercased().contains(searchText) ||
                book.author.lowercased().contains(searchText) ||
                book.publisher.lowercased().contains(searchText)
            }
            
            self.bookCardCollectionVC.reloadData(with: self.filteredBooks)
        }
    }

      func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           searchController.isActive = false
           
           isSearching = false
           updateLayoutForSearchState()
           navigationController?.setNavigationBarHidden(true, animated: false)
           
           // Restore original book list
           bookCardCollectionVC.reloadData(with: books)
           
           // Prevent tabbar from becoming transparent
           tabBarController?.tabBar.backgroundColor = Constants.Colors.mainBackground
      }
    
    
}


/*
if let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
    print("Documents Directory: \(documentsDirectoryURL)")
}
*/
