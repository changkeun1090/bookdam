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
        tableView.delegate = self
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
        
        let (_, imageHeight) = Constants.BookImageSize.calculate(type: .card)

        let cellHeight = imageHeight + Constants.Layout.smMargin*2
        
        return cellHeight 
    }
    
    // Handle the cell tap to navigate to BookDetailVC
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBook = books[indexPath.row]
        let bookDetailVC = BookDetailVC()        
        bookDetailVC.configure(with: selectedBook)
        bookDetailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(bookDetailVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alertController, animated: true)
        }
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
                
                if books.isEmpty && page == 1 {
                          self.showAlert(
                              title: "검색 결과 없음",
                              message: "'\(query)'에 대한 검색 결과가 없습니다."
                          )
                      }
                
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
                    self.dismissLoadingViewClosure?()
                    self.isLoading = false
                }
            case .failure(let error):
                print("Error fetching books: \(error.localizedDescription)")
                self.dismissLoadingViewClosure?()
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let contentOffsetY = scrollView.contentOffset.y
        let screenHeight = scrollView.frame.size.height
        
        if contentOffsetY + screenHeight >= contentHeight - 100 { // 100 is the threshold to trigger loading more

            if !isLoading && !books.isEmpty && hasMoreFollowers { // Avoid multiple requests at once
                isLoading = true
                currentPage += 1
                getBooks(query: searchText, page: currentPage) // Fetch more books
            }
        }
    }
}

