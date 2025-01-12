extension BooksVC: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased(), !searchText.isEmpty else {
            isSearching = false
            filteredBooks = books
            bookCardCollectionVC.reloadData(with: books)
            return
        }
        
        isSearching = true
        filteredBooks = books.filter { book in
            book.title.lowercased().contains(searchText)
        }
        bookCardCollectionVC.reloadData(with: filteredBooks)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.isActive = false
        
        isSearching = false
        updateLayoutForSearchState()
        bookCardCollectionVC.reloadData(with: books)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.backgroundColor = Constants.Colors.mainBackground
    }
}
