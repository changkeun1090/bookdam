//
//  CoreDataManager.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/11/25.
//

import Foundation

import CoreData
import UIKit

class CoreDataManager {

    static let shared = CoreDataManager()

    private init() {}
    
    // MARK: - Persistent Container
    private var persistentContainer: NSPersistentContainer {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer
    }

    // MARK: - Save Book
    func saveBook(book: Book) {
        let context = persistentContainer.viewContext
        
        // Check if the book with the same ISBN exists
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isbn == %@", book.isbn)

        do {
            let existingBooks = try context.fetch(fetchRequest)
            if existingBooks.isEmpty {
                // Create a new BookEntity and set its properties
                let newBook = BookEntity(context: context)
                newBook.title = book.title
                newBook.author = book.author
                newBook.isbn = book.isbn
                newBook.publisher = book.publisher
                newBook.cover = book.cover
                newBook.pubDate = book.pubDate
                newBook.bookDescription = book.bookDescription
                newBook.link = book.link
                
                // Save the context
                try context.save()
                print("Book saved successfully.")
            } else {
                print("Book with ISBN \(book.isbn) already exists.")
            }
        } catch {
            print("Failed to save book: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetch Books
    func fetchBooks() -> [BookEntity]? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch books: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Delete Book
    func deleteBook(book: BookEntity) {
        let context = persistentContainer.viewContext
        context.delete(book)
        
        do {
            try context.save()
            print("Book deleted successfully.")
        } catch {
            print("Failed to delete book: \(error.localizedDescription)")
        }
    }
    
    func deleteBookwithIsbn(by isbn: String) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        
        // Filter the BookEntity by ISBN
        fetchRequest.predicate = NSPredicate(format: "isbn == %@", isbn)
        
        do {
            // Fetch the book with the given ISBN
            let books = try context.fetch(fetchRequest)
            
            // If the book exists, delete it
            if let bookToDelete = books.first {
                context.delete(bookToDelete)
                
                // Save the context after deletion
                try context.save()
                print("Book deleted successfully.")
            } else {
                print("No book found with ISBN: \(isbn)")
            }
        } catch {
            print("Failed to delete book: \(error.localizedDescription)")
        }
    }

    
    // MARK: - Fetch Book by ISBN
    func fetchBookByISBN(isbn: String) -> BookEntity? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isbn == %@", isbn)

        do {
            let result = try context.fetch(fetchRequest)
            return result.first
        } catch {
            print("Failed to fetch book by ISBN: \(error.localizedDescription)")
            return nil
        }
    }
    
    func isBookExist(isbn: String) -> Bool {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isbn == %@", isbn)

        do {
            let result = try context.fetch(fetchRequest)
            return !result.isEmpty  // Return true if the result is not empty (i.e., the book exists)
        } catch {
            print("Failed to fetch book by ISBN: \(error.localizedDescription)")
            return false // Return false if there's an error
        }
    }

}
