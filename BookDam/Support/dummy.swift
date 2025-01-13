// MARK: - BooksViewState
struct BooksViewState {
    var isSearching: Bool = false
    var isSelectMode: Bool = false
    var selectedBookISBNs: Set<String> = []
    var currentSortOrder: SortOrder = UserDefaultsManager.shared.sortOrder
    
    mutating func toggleSelectMode() {
        isSelectMode.toggle()
        if !isSelectMode {
            selectedBookISBNs.removeAll()
        }
    }
    
    var isDeleteEnabled: Bool {
        !selectedBookISBNs.isEmpty
    }
}

// MARK: - BooksViewUIConfiguration
class BooksViewUIConfiguration {
    // UI Components
    let tagButton = IconButton(title: "태그", image: nil, action: nil)
    let moreButton = IconButton(title: nil, image: Constants.Icons.more, action: nil)
    let searchButton = IconButton(title: nil, image: Constants.Icons.search, action: nil)
    let cancelButton = IconButton(title: "취소", image: nil, action: nil)
    let deleteButton = IconButton(title: "삭제", image: "", action: nil, color: Constants.Colors.warning)
    let selectAllButton = IconButton(title: "모두선택", image: "", action: nil)
    
    lazy var rightStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [searchButton, moreButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = Constants.Layout.mdMargin
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [tagButton, rightStackView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: Constants.Layout.layoutMargin,
                                             left: Constants.Layout.layoutMargin,
                                             bottom: 0,
                                             right: Constants.Layout.layoutMargin)
        return stackView
    }()
    
    func setupSearchController() -> UISearchController {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "저장된 책의 제목을 입력해주세요"
        searchController.searchBar.tintColor = Constants.Colors.accent
        return searchController
    }
}

class BooksVC: UIViewController {
    // MARK: - Properties
    private let bookCardCollectionVC = BookCardCollectionVC()
    private var searchController: UISearchController!
    private var searchTimer: Timer?
    
    private var books: [Book] = []
    private var filteredBooks: [Book] = []
    private var state = BooksViewState()
    private let uiConfig = BooksViewUIConfiguration()
    
    private var collectionViewTopConstraint: NSLayoutConstraint!
    private var horizontalStackViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialConfiguration()
        setupUI()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViewForCurrentState()
    }
    
    // MARK: - Setup Methods
    private func setupInitialConfiguration() {
        view.backgroundColor = Constants.Colors.mainBackground
        searchController = uiConfig.setupSearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupActions() {
        uiConfig.searchButton.addTarget(self, action: #selector(showSearchBar), for: .touchUpInside)
        uiConfig.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        uiConfig.deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        uiConfig.selectAllButton.addTarget(self, action: #selector(selectAllButtonTapped), for: .touchUpInside)
        configureMoreButton()
    }
    
    // MARK: - UI Update Methods
    private func updateViewForCurrentState() {
        if !state.isSearching {
            navigationController?.setNavigationBarHidden(true, animated: false)
            fetchAllBooks()
            sortBooks(by: state.currentSortOrder)
            bookCardCollectionVC.reloadData(with: books)
        }
    }
    
    private func updateLayoutForSearchState() {
        uiConfig.horizontalStackView.isHidden = state.isSearching
        horizontalStackViewHeightConstraint.constant = state.isSearching ? 0 : 30
        collectionViewTopConstraint.constant = state.isSearching ? 0 : Constants.Layout.layoutMargin
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Book Management Methods
    func fetchAllBooks() {
        if let bookEntities = CoreDataManager.shared.fetchBooks() {
            self.books = bookEntities
        } else {
            print("Failed to fetch books from Core Data")
        }
    }
    
    private func sortBooks(by order: SortOrder) {
        state.currentSortOrder = order
        UserDefaultsManager.shared.sortOrder = order
        
        let sortClosure: (Book, Book) -> Bool = { book1, book2 in
            let date1 = book1.createdAt ?? .distantPast
            let date2 = book2.createdAt ?? .distantPast
            return order == .newest ? date1 > date2 : date1 < date2
        }
        
        books.sort(by: sortClosure)
        
        if state.isSearching {
            filteredBooks.sort(by: sortClosure)
        }
        
        configureMoreButton()
        bookCardCollectionVC.reloadData(with: state.isSearching ? filteredBooks : books)
    }
    
    // MARK: - Selection Mode Methods
    private func enterSelectMode() {
        state.toggleSelectMode()
        updateUIForSelectMode(true)
        bookCardCollectionVC.enterSelectMode()
    }
    
    private func exitSelectMode() {
        state.toggleSelectMode()
        updateUIForSelectMode(false)
        bookCardCollectionVC.exitSelectMode()
    }
    
    private func updateUIForSelectMode(_ isSelectMode: Bool) {
        if isSelectMode {
            // Selection mode UI setup
            uiConfig.tagButton.removeFromSuperview()
            uiConfig.moreButton.removeFromSuperview()
            uiConfig.searchButton.removeFromSuperview()
            
            uiConfig.horizontalStackView.insertArrangedSubview(uiConfig.cancelButton, at: 0)
            uiConfig.rightStackView.addArrangedSubview(uiConfig.selectAllButton)
            uiConfig.rightStackView.addArrangedSubview(uiConfig.deleteButton)
        } else {
            // Normal mode UI setup
            uiConfig.horizontalStackView.arrangedSubviews.first?.removeFromSuperview()
            uiConfig.selectAllButton.removeFromSuperview()
            uiConfig.deleteButton.removeFromSuperview()
            
            uiConfig.horizontalStackView.insertArrangedSubview(uiConfig.tagButton, at: 0)
            uiConfig.rightStackView.addArrangedSubview(uiConfig.searchButton)
            uiConfig.rightStackView.addArrangedSubview(uiConfig.moreButton)
        }
    }
}

// MARK: - Action Methods
extension BooksVC {
    @objc private func showSearchBar() {
        state.isSearching = true
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
        let selectedCount = state.selectedBookISBNs.count
        
        showConfirmationAlert(
            title: "총 \(selectedCount)권을 삭제하시겠습니까?",
            message: "",
            confirmActionTitle: "삭제",
            cancelActionTitle: "취소"
        ) {
            self.deleteSelectedBooks()
        }
    }
    
    private func deleteSelectedBooks() {
        state.selectedBookISBNs.forEach { isbn in
            CoreDataManager.shared.deleteBookwithIsbn(by: isbn)
        }
        
        books.removeAll { state.selectedBookISBNs.contains($0.isbn) }
        filteredBooks.removeAll { state.selectedBookISBNs.contains($0.isbn) }
        
        exitSelectMode()
        bookCardCollectionVC.reloadData(with: books)
    }
    
    @objc private func selectAllButtonTapped() {
        bookCardCollectionVC.toggleSelectAll()
    }
}

// Rest of the extensions (UISearchResultsUpdating, UISearchBarDelegate, etc.)
// would follow similar refactoring patterns...
