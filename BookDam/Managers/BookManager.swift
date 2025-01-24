//
//  BookManager.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/13/25.
//

import Foundation
import CoreData

// Protocol to notify about book changes
protocol BookManagerDelegate: AnyObject {
    func bookManager(_ manager: BookManager, didUpdateBooks books: [Book])
    func bookManager(_ manager: BookManager, didDeleteBooks isbns: Set<String>)
}

class BookManager {
    
    // MARK: - Properties
    
    // Singleton instance for global access
    static let shared = BookManager()
    
    // Delegate to notify about changes
    weak var delegate: BookManagerDelegate?
    
    private(set) var books: [Book] = []
    private(set) var filteredBooks: [Book] = []
    
    private(set) var appliedTagFilters: Set<UUID> = []

    private var currentSortOrder: SortOrder {
        get { UserDefaultsManager.shared.sortOrder }
        set { UserDefaultsManager.shared.sortOrder = newValue }
    }
    
    // MARK: - Initialization
    
    private init() {
        loadBooks()
    }
    
    // MARK: - Public Methods
    
    func loadBooks() {
        if let bookEntities = CoreDataManager.shared.fetchBooks() {
            self.books = bookEntities
            sortBooks(by: currentSortOrder)
            delegate?.bookManager(self, didUpdateBooks: books)
        }
    }
        
    func filterBooks(with searchText: String) {
        guard !searchText.isEmpty else {
            filteredBooks = []
            delegate?.bookManager(self, didUpdateBooks: [])
            return
        }
        
        let lowercasedText = searchText.lowercased()
        filteredBooks = books.filter { book in
            book.title.lowercased().contains(lowercasedText) ||
            book.author.lowercased().contains(lowercasedText) ||
            book.publisher.lowercased().contains(lowercasedText)
        }
                
//        sortBooks(by: currentSortOrder, isFiltered: true)
        delegate?.bookManager(self, didUpdateBooks: filteredBooks)
    }

    /*
    func deleteBooks(with isbns: Set<String>) {
        
        isbns.forEach { isbn in
            CoreDataManager.shared.deleteBookwithIsbn(by: isbn)
        }
        
        books.removeAll { isbns.contains($0.isbn) }
        filteredBooks.removeAll { isbns.contains($0.isbn) }
        
        delegate?.bookManager(self, didDeleteBooks: isbns)
    }
     */
    
    func deleteBooks(with isbns: Set<String>) {
        // Ensure UI updates happen on main thread
        DispatchQueue.main.async { [weak self] in
            isbns.forEach { isbn in
                CoreDataManager.shared.deleteBookwithIsbn(by: isbn)
            }
            self?.loadBooks() // Refresh the books array after all deletions
            self?.delegate?.bookManager(self!, didDeleteBooks: isbns)
        }
    }
    func deleteBook(with isbn: String) {
        deleteBooks(with: Set([isbn]))
    }

    func changeSortOrder(to order: SortOrder) {
        currentSortOrder = order
        sortBooks(by: order)
        delegate?.bookManager(self, didUpdateBooks: books)
    }
    
    func getCurrentBooks(isSearching: Bool) -> [Book] {
        return isSearching ? filteredBooks : books
    }
    
    // MARK: - Private Methods
    private func sortBooks(by order: SortOrder, isFiltered: Bool = false) {
        let _ = isFiltered ? filteredBooks : books
        
        switch order {
        case .newest:
            if isFiltered {
                filteredBooks.sort { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
            } else {
                books.sort { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
            }
        case .oldest:
            if isFiltered {
                filteredBooks.sort { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) }
            } else {
                books.sort { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) }
            }
        }
    }
    
    // MARK: - TAG Filterling
    
    func getFilteredBooks(byTags tagIds: Set<UUID>) -> [Book] {
        appliedTagFilters = tagIds
        
        if tagIds.isEmpty {
            return books
        }
        
        return books.filter { book in
            guard let bookTags = book.tags else {
                return false
            }
            
            let bookTagIds = Set(bookTags.map { $0.id })
            return tagIds.isSubset(of: bookTagIds)
        }
    }
    
    // Optional: Method to clear filters
    func clearTagFilters() {
        appliedTagFilters.removeAll()
        loadBooks() // This will trigger delegate update with all books
    }
}

// MARK: - CloudKit
extension BookManager {
    func handleCloudKitChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStoreRemoteChange),
            name: .NSPersistentStoreRemoteChange,
            object: nil
        )
    }
    
    @objc private func handleStoreRemoteChange(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.loadBooks()
        }
    }
}
