//
//  BookListCollectionVC.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/7/25.
//

import UIKit

class BookListTableVC: UITableViewController {
    
    var searchText: String!
    var books: [Book] = []
    
    var currentPage = 1
    var isLoading = false
    var hasMoreFollowers = true

    var dismissLoadingViewClosure: (() -> Void)?
    var showLoadingViewClosure: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self // Setting the delegate here
        view.backgroundColor = Constants.Colors.mainBackground
        self.tableView.register(BookListCell.self, forCellReuseIdentifier: "BookListCell")
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookListCell", for: indexPath) as! BookListCell
                
        let book = books[indexPath.row]
        cell.configure(with: book)        
        
        return cell
    }
        
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let (_, imageHeight) = Constants.Size.calculateImageSize()
        
        let cellHeight = imageHeight + Constants.Layout.smMargin*2
        
        // Return the height of the image
        return cellHeight // Add some padding for title and labels
    }
    
    // Handle the cell tap to navigate to BookDetailVC
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBook = books[indexPath.row]
        let bookDetailVC = BookDetailVC()        
        bookDetailVC.configure(with: selectedBook)
        bookDetailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(bookDetailVC, animated: true)
    }
    
    func searchBook(query: String) {
        self.searchText = query
        getBooks(query: searchText, page: currentPage)
    }
    
    func getBooks(query: String, page: Int) {
        
        DispatchQueue.main.async {
            self.showLoadingViewClosure?()
        }
        
        NetworkManager.shared.searchBooks(query: query, page: String(page)) { result in
            switch result {
            case .success(let books):
                
                if books.count < 20 {
                    self.hasMoreFollowers = false
                }
                
                if page == 1 {
                    self.books = books
                } else {
                    self.books.append(contentsOf: books)
                }
                
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.dismissLoadingViewClosure?() // Call dismiss closure after books are fetched                    
                    self.isLoading = false
                }
            case .failure(let error):
                print("Error fetching books: \(error.localizedDescription)")
                self.dismissLoadingViewClosure?() // Call dismiss closure after books are fetched
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let contentOffsetY = scrollView.contentOffset.y
        let screenHeight = scrollView.frame.size.height
        
        // If the bottom of the table view is within a threshold of the bottom of the screen
        if contentOffsetY + screenHeight >= contentHeight - 100 { // 100 is the threshold to trigger loading more

            if !isLoading && !books.isEmpty && hasMoreFollowers { // Avoid multiple requests at once
                isLoading = true
                currentPage += 1
                getBooks(query: searchText, page: currentPage) // Fetch more books
            }
        }
    }
}

