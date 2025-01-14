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
    
    // MARK: - Properties
    private var searchController: UISearchController!
    private let bookCardCollectionVC = BookCardCollectionVC()
    private let bookManager: BookManager = .shared
        
    // Track current state
    private var isSearching = false {
        didSet {
            updateNavigationItems()
        }
    }
    private var isSelectMode = false
    private var selectedBookISBNs = Set<String>()
    private var searchTimer: Timer?
    
    // MARK: - Navigation Items
    
    private lazy var tagBarButton: UIBarButtonItem = {
        NavigationButtonFactory.createTextButton(
            title: "태그",
            style: .accent,
            target: self,
            action: #selector(tagButtonTapped)
        )
    }()
    
    private lazy var searchBarButton: UIBarButtonItem = {
        NavigationButtonFactory.createImageButton(
            image: Constants.Icons.search,
            style: .accent,
            target: self,
            action: #selector(showSearchBar)
        )
    }()
    
    private lazy var moreBarButton: UIBarButtonItem = {
        NavigationButtonFactory.createMenuButton(
            image: Constants.Icons.more,
            menu: createMoreButtonMenu(),
            style: .accent
        )
    }()
    
    private lazy var cancelBarButton: UIBarButtonItem = {
        NavigationButtonFactory.createTextButton(
            title: "취소",
            style: .accent,
            target: self,
            action: #selector(cancelButtonTapped)
        )
    }()
    
    private lazy var selectAllBarButton: UIBarButtonItem = {
        NavigationButtonFactory.createTextButton(
            title: "모두선택",
            style: .accent,
            target: self,
            action: #selector(selectAllButtonTapped)
        )
    }()
    
    private lazy var deleteBarButton: UIBarButtonItem = {
        NavigationButtonFactory.createTextButton(
            title: "삭제",
            style: .warning,
            target: self,
            action: #selector(deleteButtonTapped)
        )
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialState()
        configureUI()
        setupDelegates()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bookManager.loadBooks()        
    }
    
    // MARK: - Setup Methods
    private func setupInitialState() {
        view.backgroundColor = Constants.Colors.mainBackground
        bookManager.delegate = self  // ??
    }
    
    private func configureUI() {
        configureSearchController()
        setupChildViewController()
        updateNavigationItems()
    }
    
    private func setupDelegates() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
    }
    
    private func setupChildViewController() {
        addChild(bookCardCollectionVC)
        view.addSubview(bookCardCollectionVC.view)
        setupCollectionViewConstraints()
        bookCardCollectionVC.didMove(toParent: self)
    }
     
    // MARK: - UI Configuration
    private func setupCollectionViewConstraints() {
        bookCardCollectionVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bookCardCollectionVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bookCardCollectionVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bookCardCollectionVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bookCardCollectionVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "저장된 책의 제목을 입력해주세요"
        searchController.searchBar.tintColor = Constants.Colors.accent
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // MARK: - Navigation Item Management
    private func updateNavigationItems() {
        
        if isSelectMode {
            navigationItem.leftBarButtonItem = cancelBarButton
            navigationItem.rightBarButtonItems = [deleteBarButton, selectAllBarButton]
            navigationItem.searchController = nil
        } else if isSearching {
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItems = nil
            navigationItem.searchController = searchController
        } else {
            navigationItem.leftBarButtonItem = tagBarButton
            navigationItem.rightBarButtonItems = [moreBarButton, searchBarButton]
            navigationItem.searchController = nil
        }
    }
    
    private func createMoreButtonMenu() -> UIMenu {
        let actions = createMoreButtonActions()
        return UIMenu(children: actions)
    }
    
    private func createMoreButtonActions() -> [UIMenuElement] {
        // Create the selection action
        let selectAction = UIAction(
            title: "선택하기",
            image: UIImage(systemName: Constants.Icons.checkWithCircle)
        ) { [weak self] _ in
            self?.enterSelectMode()
        }
        
        // Create sort actions
        let currentSortOrder = UserDefaultsManager.shared.sortOrder
        
        let newestAction = UIAction(
            title: "최신 항목 순으로",
            state: currentSortOrder == .newest ? .on : .off
        ) { [weak self] _ in
            self?.bookManager.changeSortOrder(to: .newest)
        }
        
        let oldestAction = UIAction(
            title: "오래된 항목 순으로",
            state: currentSortOrder == .oldest ? .on : .off
        ) { [weak self] _ in
            self?.bookManager.changeSortOrder(to: .oldest)
        }
        
        let sortMenu = UIMenu(
            title: "",
            options: .displayInline,
            children: [newestAction, oldestAction]
        )
        
        return [selectAction, sortMenu]
    }
    
    // MARK: - Selection Mode Handling
    private func enterSelectMode() {
        isSelectMode = true
        updateNavigationItems()
        bookCardCollectionVC.enterSelectMode()
    }
    
    private func exitSelectMode() {
        isSelectMode = false
        selectedBookISBNs.removeAll()
        updateNavigationItems()
        bookCardCollectionVC.exitSelectMode()
    }
    
    private func updateSelectAllButtonState() {
        let allSelected = selectedBookISBNs.count == bookManager.getCurrentBooks(isSearching: isSearching).count
        selectAllBarButton.title = allSelected ? "선택 해제" : "모두선택"
    }
    
    func updateSelectedBooks(_ isbns: [String]) {
        selectedBookISBNs = Set(isbns)
        updateDeleteButtonState()
        updateSelectAllButtonState()
    }
    
    private func updateDeleteButtonState() {
        deleteBarButton.isEnabled = !selectedBookISBNs.isEmpty
        deleteBarButton.tintColor = deleteBarButton.isEnabled ? Constants.Colors.warning : Constants.Colors.warning.withAlphaComponent(0.5)
    }
    
    // MARK: - Button Actions
    @objc private func tagButtonTapped() {
        // Implement tag functionality
    }
    
    @objc private func showSearchBar() {
        bookCardCollectionVC.reloadData(with: [])
        isSearching = true
        searchController.isActive = true
        searchController.searchBar.becomeFirstResponder()
    }
    
    @objc private func cancelButtonTapped() {
        exitSelectMode()
    }
    
    @objc private func deleteButtonTapped() {
        let selectedCount = selectedBookISBNs.count
        showConfirmationAlert(
            title: "총 \(selectedCount)권을 삭제하시겠습니까?",
            message: "",
            confirmActionTitle: "삭제",
            cancelActionTitle: "취소"
        ) { [weak self] in
            self?.bookManager.deleteBooks(with: self?.selectedBookISBNs ?? [])
            self?.exitSelectMode()
        }
    }
    
    @objc private func selectAllButtonTapped() {
        bookCardCollectionVC.toggleSelectAll()
    }
}

// MARK: - BookManagerDelegate
extension BooksVC: BookManagerDelegate {
    func bookManager(_ manager: BookManager, didUpdateBooks books: [Book]) {
        DispatchQueue.main.async {
            self.bookCardCollectionVC.reloadData(with: books)
            self.moreBarButton.menu = self.createMoreButtonMenu()
        }
    }
    
    func bookManager(_ manager: BookManager, didDeleteBooks isbns: Set<String>) {
        DispatchQueue.main.async {
            let currentBooks = manager.getCurrentBooks(isSearching: self.isSearching)
            self.bookCardCollectionVC.reloadData(with: currentBooks)        
        }
    }
}

// MARK: - BooksDeletionDelegate
extension BooksVC: BooksDeletionDelegate {
    func didDeleteBook(withIsbn isbn: String) {
        bookManager.deleteBook(with: isbn)
    }
}

// MARK: - UISearchResultsUpdating & UISearchBarDelegate
extension BooksVC: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        searchTimer?.invalidate()
        
        guard let searchText = searchController.searchBar.text?.lowercased(),
              !searchText.isEmpty else {
            bookCardCollectionVC.reloadData(with: [])
            return
        }
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let self = self,
                  self.isSearching else { return }
            
            self.bookManager.filterBooks(with: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        bookManager.loadBooks()
        isSearching = false
        searchController.isActive = false
        tabBarController?.tabBar.backgroundColor = Constants.Colors.mainBackground
    }
}
