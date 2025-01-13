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
    
    // Child View Controllers
    private let bookCardCollectionVC = BookCardCollectionVC()
    
    // Managers
    private let bookManager: BookManager = .shared
    
    // UI Components
    private var searchController: UISearchController!
    private let tagButton = IconButton(title: "태그", image: nil, action: nil)
    private let moreButton = IconButton(title: nil, image: Constants.Icons.more, action: nil)
    private let searchButton = IconButton(title: nil, image: Constants.Icons.search, action: nil)
    private let cancelButton = IconButton(title: "취소", image: nil, action: nil)
    private let deleteButton = IconButton(title: "삭제", image: "", action: nil, color: Constants.Colors.warning)
    private let selectAllButton = IconButton(title: "모두선택", image: "", action: nil)
    
    // Stack Views
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
        stackView.layoutMargins = UIEdgeInsets(top: Constants.Layout.layoutMargin,
                                             left: Constants.Layout.layoutMargin,
                                             bottom: 0,
                                             right: Constants.Layout.layoutMargin)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    // State Management
    private var isSearching = false {
        didSet {
            updateLayoutForSearchState()
        }
    }
    private var isSelectMode = false
    private var selectedBookISBNs = Set<String>()
    private var searchTimer: Timer?
    
    // Constraints
    private var collectionViewTopConstraint: NSLayoutConstraint!
    private var horizontalStackViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialState()
        configureUI()
        setupDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleViewWillAppear()
    }
    
    // MARK: - Setup Methods
    
    private func setupInitialState() {
        view.backgroundColor = Constants.Colors.mainBackground
        bookManager.delegate = self
    }
    
    private func configureUI() {
        configureSearchController()
        configureMoreButton()
        setupStackViews()
        setupChildViewController()
    }
    
    private func setupDelegates() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
    }
    
    private func setupStackViews() {
        view.addSubview(horizontalStackView)
        setupStackViewConstraints()
        configureButtonActions()
    }
    
    private func setupChildViewController() {
        addChild(bookCardCollectionVC)
        view.addSubview(bookCardCollectionVC.view)
        setupCollectionViewConstraints()
        bookCardCollectionVC.didMove(toParent: self)
    }
    
    // MARK: - UI Configuration
    
    private func setupStackViewConstraints() {
        horizontalStackViewHeightConstraint = horizontalStackView.heightAnchor.constraint(equalToConstant: 30)
        
        NSLayoutConstraint.activate([
            horizontalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            horizontalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            horizontalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            horizontalStackViewHeightConstraint
        ])
    }
    
    private func setupCollectionViewConstraints() {
        bookCardCollectionVC.view.translatesAutoresizingMaskIntoConstraints = false
        collectionViewTopConstraint = bookCardCollectionVC.view.topAnchor.constraint(equalTo: horizontalStackView.bottomAnchor)
        
        NSLayoutConstraint.activate([
            collectionViewTopConstraint,
            bookCardCollectionVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bookCardCollectionVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bookCardCollectionVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureButtonActions() {
        searchButton.addTarget(self, action: #selector(showSearchBar), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        selectAllButton.addTarget(self, action: #selector(selectAllButtonTapped), for: .touchUpInside)
    }
    
    private func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "저장된 책의 제목을 입력해주세요"
        searchController.searchBar.tintColor = Constants.Colors.accent
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func configureMoreButton() {
        let actions = createMoreButtonActions()
        let menu = UIMenu(children: actions)
        moreButton.menu = menu
        moreButton.showsMenuAsPrimaryAction = true
    }
    
    private func createMoreButtonActions() -> [UIMenuElement] {
        let selectAction = UIAction(
            title: "선택하기",
            image: UIImage(systemName: Constants.Icons.checkWithCircle)
        ) { [weak self] _ in
            self?.enterSelectMode()
        }
        
        let sortOrder = UserDefaultsManager.shared.sortOrder
        let sortActions = [
            createSortAction(for: .newest, currentOrder: sortOrder),
            createSortAction(for: .oldest, currentOrder: sortOrder)
        ]
        
        let sortMenu = UIMenu(title: "", options: .displayInline, children: sortActions)
        
        return [selectAction, sortMenu]
    }
    
    private func createSortAction(for order: SortOrder, currentOrder: SortOrder) -> UIAction {
        UIAction(
            title: order.displayTitle,
            state: order == currentOrder ? .on : .off
        ) { [weak self] _ in
            self?.bookManager.changeSortOrder(to: order)
        }
    }
    
    // MARK: - Selection Mode Handling
    
    private func enterSelectMode() {
        isSelectMode = true
        updateUIForSelectMode(true)
        bookCardCollectionVC.enterSelectMode()
    }
    
    private func exitSelectMode() {
        isSelectMode = false
        selectedBookISBNs.removeAll()
        updateUIForSelectMode(false)
        bookCardCollectionVC.exitSelectMode()
    }
    
    private func updateUIForSelectMode(_ isSelecting: Bool) {
        if isSelecting {
            tagButton.removeFromSuperview()
            moreButton.removeFromSuperview()
            searchButton.removeFromSuperview()
            
            horizontalStackView.insertArrangedSubview(cancelButton, at: 0)
            rightStackView.addArrangedSubview(selectAllButton)
            rightStackView.addArrangedSubview(deleteButton)
        } else {
            horizontalStackView.arrangedSubviews.first?.removeFromSuperview()
            selectAllButton.removeFromSuperview()
            deleteButton.removeFromSuperview()
            
            horizontalStackView.insertArrangedSubview(tagButton, at: 0)
            rightStackView.addArrangedSubview(searchButton)
            rightStackView.addArrangedSubview(moreButton)
        }
    }
    
    // MARK: - View State Updates
    
    private func updateLayoutForSearchState() {
        horizontalStackView.isHidden = isSearching
        horizontalStackViewHeightConstraint.constant = isSearching ? 0 : 30
        collectionViewTopConstraint.constant = isSearching ? 0 : Constants.Layout.layoutMargin
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func handleViewWillAppear() {
        if !isSearching {
            navigationController?.setNavigationBarHidden(true, animated: false)
            bookManager.loadBooks()
        }
    }
    
    // MARK: - Button Actions
    
    @objc private func showSearchBar() {
        isSearching = true
        navigationController?.setNavigationBarHidden(false, animated: false)
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
        bookCardCollectionVC.reloadData(with: books)
    }
    
    func bookManager(_ manager: BookManager, didDeleteBooks isbns: Set<String>) {
        bookCardCollectionVC.reloadData(with: manager.getCurrentBooks(isSearching: isSearching))
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
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let self = self,
                  self.isSearching,
                  let searchText = searchController.searchBar.text?.lowercased() else { return }
            
            self.bookManager.filterBooks(with: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchController.isActive = false
        navigationController?.setNavigationBarHidden(true, animated: false)
        bookManager.loadBooks()
        tabBarController?.tabBar.backgroundColor = Constants.Colors.mainBackground
    }
}

// MARK: - SortOrder Extension

private extension SortOrder {
    var displayTitle: String {
        switch self {
        case .newest: return "최신 항목 순으로"
        case .oldest: return "오래된 항목 순으로"
        }
    }
}
