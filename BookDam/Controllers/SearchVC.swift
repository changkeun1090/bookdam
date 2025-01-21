//
//  SearchVC.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/3/25.
//

import UIKit
import AVFoundation

class SearchVC: DataLoadingVC {
    
    private var books: [Book] = []
    private var bookListTableVC = BookListTableVC()
    private var currentPage = 1
    private var isLoading = false

    var quoteViewHeightConstraint:NSLayoutConstraint!

    private lazy var quoteView: QuotesView = {
        let quoteView = QuotesView(frame: .zero)
        quoteView.translatesAutoresizingMaskIntoConstraints = false
        return quoteView
    }()
    
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "제목, 지은이, 출판사"
        controller.searchBar.tintColor = Constants.Colors.accent
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.Colors.mainBackground        
        setupUI()
    }
    
    private func setupUI() {
        
        bookListTableVC.dismissLoadingViewClosure = { [weak self] in
              self?.dismissLoadingView()
          }
        
        bookListTableVC.showLoadingViewClosure = { [weak self] in
              self?.showLoadingView()
          }
                
        setupQuoteView()
        setupSearchController()
        setupBookListTable()
        self.bookListTableVC.view.isHidden = true
    }
    
    private func setupQuoteView() {
        quoteView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(quoteView)
        
        quoteViewHeightConstraint = quoteView.heightAnchor.constraint(equalToConstant: 300)
        
        NSLayoutConstraint.activate([
            quoteView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            quoteView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            quoteView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            quoteViewHeightConstraint
        ])
    }
    
    private func setupSearchController() {
        searchController.searchBar.delegate = self
        
        let barcodeImage = UIImage(systemName: "barcode.viewfinder")
        searchController.searchBar.showsBookmarkButton = true

        searchController.searchBar.setImage(barcodeImage, for: .bookmark, state: .normal)
        searchController.searchBar.showsBookmarkButton = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupBookListTable() {
        
        bookListTableVC.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(bookListTableVC)
        view.addSubview(bookListTableVC.view)
        
        NSLayoutConstraint.activate([
            bookListTableVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            bookListTableVC.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            bookListTableVC.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            bookListTableVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
        ])
        
    }
}

extension SearchVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
         self.searchController.searchBar.showsBookmarkButton = false
         self.quoteViewHeightConstraint.constant = 0
         self.bookListTableVC.view.isHidden = false
         self.quoteView.alpha = 0
         
     }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
          UIView.animate(withDuration: 0.5) {
              self.searchController.searchBar.showsBookmarkButton = true
              self.quoteViewHeightConstraint.constant = 300
              self.quoteView.alpha = 1
              self.bookListTableVC.view.isHidden = true
              self.books = []
              self.bookListTableVC.books = self.books
              self.bookListTableVC.tableView.reloadData()
          }
      }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        if let searchText = searchBar.text, !searchText.isEmpty {
            self.books = []
            self.bookListTableVC.books = self.books
            self.bookListTableVC.tableView.reloadData()
            self.bookListTableVC.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            bookListTableVC.searchBook(query: searchText)
        }
    }
}
