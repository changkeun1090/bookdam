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
    private var selectedBookISBNs = Set<String>()
    
    private var searchTimer: Timer?
    
    private var isSearching = false
    private var isSelectMode = false

    private var collectionViewTopConstraint: NSLayoutConstraint!
    private var horizontalStackViewHeightConstraint: NSLayoutConstraint!
    
    private let tagButton = IconButton(title: "태그", image: nil, action: nil)
    private let moreButton = IconButton(title: nil, image: Constants.Icons.more, action: nil)
    private let searchButton = IconButton(title: nil, image: Constants.Icons.search, action: nil)
    private let cancelButton = IconButton(title: "취소", image: nil, action: nil)
    private let deleteButton = IconButton(title: "삭제", image: "", action: nil, color: Constants.Colors.warning)
    private let selectAllButton = IconButton(title: "모두선택", image: "", action: nil)
    
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
        configureSearchController()
        configureMoreButton()
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isSearching {
             navigationController?.setNavigationBarHidden(true, animated: false)
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
    private func configureSearchController() {
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
    
    // MARK: - MoreButton
    private func configureMoreButton() {
        // Create menu actions
        let selectAction = UIAction(title: "선택하기", image: UIImage(systemName: Constants.Icons.checkWithCircle)) { [weak self] _ in
            self?.enterSelectMode()  // Add this line

            // We'll implement this functionality later
            print("Select tapped")
        }
        
        let sortRecentAction = UIAction(title: "최신 항목 순으로", image: UIImage(systemName: Constants.Icons.check)) { _ in
            // We'll implement this functionality later
            print("Sort by Recent tapped")
        }
        
        let sortOldAction = UIAction(title: "오래된 항목 순으로", image: nil) { _ in
            // We'll implement this functionality later
            print("Sort by Old tapped")
        }
                        
        let menu = UIMenu(children: [
             selectAction,
             UIMenu(title: "", options: .displayInline, children: [sortRecentAction, sortOldAction])
         ])
        
        moreButton.menu = menu
        moreButton.showsMenuAsPrimaryAction = true
        
    }

    
    private func enterSelectMode() {
        isSelectMode = true
        
        tagButton.removeFromSuperview()
        moreButton.removeFromSuperview()
        searchButton.removeFromSuperview()
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        selectAllButton.addTarget(self, action: #selector(selectAllButtonTapped), for: .touchUpInside)
        
        horizontalStackView.insertArrangedSubview(cancelButton, at: 0)
        rightStackView.addArrangedSubview(selectAllButton)
        rightStackView.addArrangedSubview(deleteButton)
        
        bookCardCollectionVC.enterSelectMode()

    }

    private func exitSelectMode() {
        isSelectMode = false
                
        horizontalStackView.arrangedSubviews.first?.removeFromSuperview()
        selectAllButton.removeFromSuperview()
        deleteButton.removeFromSuperview()
                
        horizontalStackView.insertArrangedSubview(tagButton, at: 0)
        rightStackView.addArrangedSubview(searchButton)
        rightStackView.addArrangedSubview(moreButton)
                                
        bookCardCollectionVC.exitSelectMode()
    }
    
    func updateSelectedBooks(_ isbns: [String]) {
        selectedBookISBNs = Set(isbns)
        
        // Update UI based on selection state
        deleteButton.isEnabled = !selectedBookISBNs.isEmpty
        deleteButton.alpha = deleteButton.isEnabled ? 1.0 : 0.5
        
//        updateSelectAllButtonState()
    }
    
    

        
    @objc private func showSearchBar() {
        isSearching = true  // Set this first
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        searchController.isActive = true
        searchController.searchBar.becomeFirstResponder()
        
        updateLayoutForSearchState()
        
        bookCardCollectionVC.reloadData(with: [])
    }
    
    @objc private func cancelButtonTapped() {
        exitSelectMode()
    }
    
    @objc private func deleteButtonTapped() {
        print("Delete tapped")        
        
        let selectedCount = selectedBookISBNs.count

        self.showConfirmationAlert(title: "총 \(selectedCount)권을 삭제하시겠습니까?", message: "", confirmActionTitle: "삭제", cancelActionTitle: "취소") {
            self.selectedBookISBNs.forEach { isbn in
                CoreDataManager.shared.deleteBookwithIsbn(by: isbn)
            }
            
            // Remove deleted books from our arrays
            self.books.removeAll { self.selectedBookISBNs.contains($0.isbn) }
            self.filteredBooks.removeAll { self.selectedBookISBNs.contains($0.isbn) }
            
            // Exit select mode
            self.exitSelectMode()
            
            // Reload collection view with updated data
            self.bookCardCollectionVC.reloadData(with: self.books)
        }

    }

    @objc private func selectAllButtonTapped() {
        // Toggle select all in collection view
        bookCardCollectionVC.toggleSelectAll()
      
      // Update select all button appearance based on selection state
//        updateSelectAllButtonState()
    }
    
    private func updateSelectAllButtonState() {
        let allSelected = selectedBookISBNs.count == books.count
        
        // Update button image based on selection state
        let imageName = allSelected ? "checkmark.circle.fill" : "checkmark.circle"
        selectAllButton.setImage(UIImage(systemName: imageName), for: .normal)
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
