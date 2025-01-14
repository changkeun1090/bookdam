import UIKit
import CoreData

protocol BooksDeletionDelegate: AnyObject {
    func didDeleteBook(withIsbn isbn: String)
}

private enum Layout {
    static let stackViewHeight: CGFloat = 45
    static let stackViewTopPadding: CGFloat = 0  // Remove top margin from stack view
    static let collectionViewTopMargin: CGFloat = 0 // No additional margin needed
}

class BooksVC: UIViewController {
    
    private var searchController: UISearchController!
    private let bookCardCollectionVC = BookCardCollectionVC()
    
    private let bookManager: BookManager = .shared
    
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
        
        return stackView
    }()
    
    private var isSearching = false {
        didSet {
            horizontalStackView.isHidden = isSearching
        }
    }
    private var isSelectMode = false
    private var selectedBookISBNs = Set<String>()
    private var searchTimer: Timer?
        
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupInitialState()
        setupDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bookManager.loadBooks()
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
        NSLayoutConstraint.activate([
            horizontalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Layout.layoutMargin),
            horizontalStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.Layout.layoutMargin),
            horizontalStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.Layout.layoutMargin),
            horizontalStackView.heightAnchor.constraint(equalToConstant: Layout.stackViewHeight)
        ])
    }
    
    private func setupCollectionViewConstraints() {
        bookCardCollectionVC.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bookCardCollectionVC.view.topAnchor.constraint(equalTo: horizontalStackView.bottomAnchor, constant: Constants.Layout.layoutMargin),
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
        // Create the selection action
        let selectAction = UIAction(
            title: "선택하기",
            image: UIImage(systemName: Constants.Icons.checkWithCircle)
        ) { [weak self] _ in
            self?.enterSelectMode()
        }
        
        // Create sort actions with proper state handling
        let currentSortOrder = UserDefaultsManager.shared.sortOrder
        
        // Newest sort action with state
        let newestAction = UIAction(
            title: "최신 항목 순으로",
            state: currentSortOrder == .newest ? .on : .off
        ) { [weak self] _ in
            self?.bookManager.changeSortOrder(to: .newest)
        }
        
        // Oldest sort action with state
        let oldestAction = UIAction(
            title: "오래된 항목 순으로",
            state: currentSortOrder == .oldest ? .on : .off
        ) { [weak self] _ in
            self?.bookManager.changeSortOrder(to: .oldest)
        }
        
        // Create the sort submenu
        let sortMenu = UIMenu(
            title: "",
            options: .displayInline,
            children: [newestAction, oldestAction]
        )
        
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
        updateNavForSelectMode(isSelectMode)
        bookCardCollectionVC.enterSelectMode()
    }
    
    private func exitSelectMode() {
        isSelectMode = false
        selectedBookISBNs.removeAll()
        updateNavForSelectMode(false)
        bookCardCollectionVC.exitSelectMode()
    }
    
    private func updateNavForSelectMode(_ isSelecting: Bool) {
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
    
    private func updateSelectAllButtonState() {
        // Check if all available books are currently selected
        let allSelected = selectedBookISBNs.count == bookManager.getCurrentBooks(isSearching: isSearching).count
        
        selectAllButton.setTitle(allSelected ? "선택 해제" : "모두선택", for: .normal)
    }

    func updateSelectedBooks(_ isbns: [String]) {
        // Store the selected ISBNs
        selectedBookISBNs = Set(isbns)
        
        // Update both the delete button and select all button states
        updateDeleteButtonState()
        updateSelectAllButtonState()
    }

    private func updateDeleteButtonState() {
        // Enable/disable delete button based on whether any books are selected
        deleteButton.isEnabled = !selectedBookISBNs.isEmpty
        deleteButton.alpha = deleteButton.isEnabled ? 1.0 : 0.5
    }
    
    // MARK: - Button Actions
    
    @objc private func showSearchBar() {
        bookCardCollectionVC.reloadData(with: [])

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
        // Make sure to update CollectionView on main thread
        DispatchQueue.main.async {
            self.bookCardCollectionVC.reloadData(with: books)
            self.configureMoreButton()
        }
    }
    
    func bookManager(_ manager: BookManager, didDeleteBooks isbns: Set<String>) {
        DispatchQueue.main.async {
            self.bookCardCollectionVC.reloadData(with: manager.getCurrentBooks(isSearching: self.isSearching))
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
        // Cancel any pending timer
        searchTimer?.invalidate()
        
        // If search text is empty, keep the list empty
        guard let searchText = searchController.searchBar.text?.lowercased(),
              !searchText.isEmpty else {
            bookCardCollectionVC.reloadData(with: [])
            return
        }
        
        // For non-empty search, use timer to avoid too frequent updates
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
        navigationController?.setNavigationBarHidden(true, animated: false)
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
