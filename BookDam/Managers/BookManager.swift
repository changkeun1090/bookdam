//
//  BookManager.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/13/25.
//

import Foundation
import CoreData

protocol BookManagerDelegate: AnyObject {
    func bookManager(_ manager: BookManager, didUpdateBooks books: [Book])
    func bookManager(_ manager: BookManager, didDeleteBooks isbns: Set<String>)
}

class BookManager {
    
    // MARK: - Properties
    private var isLoadingBooks = false
    private var lastHistoryToken: NSPersistentHistoryToken?
    private var isInitialSyncComplete = false
    
    static let shared = BookManager()
    
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
        print("LOAD BOOKS---------------")
        
        if !isInitialSyncComplete {
            CloudKitManager.shared.triggerSync { [weak self] error in
                if let error = error {
                    print("Initial sync failed: \(error)")
                }
                
                self?.isInitialSyncComplete = true
                self?.fetchAndUpdateBooks()
            }
        } else {
            fetchAndUpdateBooks()
        }
    }
    
    private func fetchAndUpdateBooks() {
        print("FETCH ADN UPDATE---------------")
        if let bookEntities = CoreDataManager.shared.fetchBooks() {
            self.books = bookEntities
            sortBooks(by: currentSortOrder)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.bookManager(self, didUpdateBooks: books)
            }
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
                
        delegate?.bookManager(self, didUpdateBooks: filteredBooks)
    }
    
    func deleteBooks(with isbns: Set<String>) {
        DispatchQueue.main.async { [weak self] in
            isbns.forEach { isbn in
                CoreDataManager.shared.deleteBookwithIsbn(by: isbn)
            }
            self?.loadBooks()
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
    
    func clearTagFilters() {
        appliedTagFilters.removeAll()
        loadBooks()
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
        guard let store = CoreDataManager.shared.persistentContainer.persistentStoreCoordinator.persistentStores.first else { return }
        
        let context = CoreDataManager.shared.persistentContainer.newBackgroundContext()
        context.performAndWait {
            do {
                let request = NSPersistentHistoryChangeRequest.fetchHistory(after: lastHistoryToken)
                let result = try context.execute(request) as? NSPersistentHistoryResult
                guard let transactions = result?.result as? [NSPersistentHistoryTransaction] else { return }
                
                let hasRelevantChanges = transactions.contains { transaction in
                    transaction.changes?.contains { change in
                        return change.changedObjectID.entity.name == "BookEntity" ||
                        change.changedObjectID.entity.name == "TagEntity"
                    } ?? false
                }
                
                if hasRelevantChanges {
                    loadBooks()
                }
                
                lastHistoryToken = transactions.last?.token
                
            } catch {
                print("Error checking history: \(error)")
                loadBooks()
            }
            
        }
    }
}
