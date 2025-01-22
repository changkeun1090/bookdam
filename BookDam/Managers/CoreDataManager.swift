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
    let persistentContainer: NSPersistentCloudKitContainer

    private init() {
        // MARK: - Persistent Container
        persistentContainer = NSPersistentCloudKitContainer(name: "BookDam")
        
        // Configure the persistent store
        guard let description = persistentContainer.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        persistentContainer.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // Enable automatic cloud sync
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Save Book
    
    func saveBookWithTags(book: Book, tagIds: Set<UUID>) {
        let context = persistentContainer.viewContext
        
        // First check if book already exists
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isbn == %@", book.isbn)
        
        do {
            let existingBooks = try context.fetch(fetchRequest)
            
            if existingBooks.isEmpty {
                // Create new book entity
                let newBook = BookEntity(context: context)
                newBook.title = book.title
                newBook.author = book.author
                newBook.isbn = book.isbn
                newBook.publisher = book.publisher
                newBook.cover = book.cover
                newBook.pubDate = book.pubDate
                newBook.bookDescription = book.bookDescription
                newBook.link = book.link
                newBook.createdAt = book.createdAt ?? Date()
                
                // Fetch and assign all selected tags
                let tagFetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
                tagFetchRequest.predicate = NSPredicate(format: "id IN %@", tagIds as CVarArg)
                
                let tags = try context.fetch(tagFetchRequest)
                tags.forEach { tag in
                    newBook.addToTags(tag)
                }
                
                try context.save()
                print("Book saved successfully with tags")
            } else {
                print("Book with ISBN \(book.isbn) already exists")
            }
        } catch {
            print("Failed to save book with tags: \(error.localizedDescription)")
        }
    }
    
    func updateBookWithTags(book: Book, tagIds: Set<UUID>) {
        let context = persistentContainer.viewContext
        
        // Create fetch request to find the existing book
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isbn == %@", book.isbn)
        
        do {
            let existingBooks = try context.fetch(fetchRequest)
            
            // Make sure we found the book we want to update
            guard let existingBook = existingBooks.first else {
                print("Book with ISBN \(book.isbn) not found")
                return
            }
            
            // Update basic book properties
            // Note: We don't update createdAt since it should remain as original creation time
            existingBook.title = book.title
            existingBook.author = book.author
            existingBook.publisher = book.publisher
            existingBook.cover = book.cover
            existingBook.pubDate = book.pubDate
            existingBook.bookDescription = book.bookDescription
            existingBook.link = book.link
            
            // Remove all existing tag relationships
            if let existingTags = existingBook.tags {
                existingBook.removeFromTags(existingTags)
            }
            
            // Fetch and assign new tags
            let tagFetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
            tagFetchRequest.predicate = NSPredicate(format: "id IN %@", tagIds as CVarArg)
            
            let newTags = try context.fetch(tagFetchRequest)
            newTags.forEach { tag in
                existingBook.addToTags(tag)
            }
            
            // Save the context
            try context.save()
            print("Book updated successfully with new tags")
            
        } catch {
            print("Failed to update book with tags: \(error.localizedDescription)")
        }
    }
    
    func saveBook(book: Book) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isbn == %@", book.isbn)

        do {
            let existingBooks = try context.fetch(fetchRequest)
            if existingBooks.isEmpty {
                let newBook = BookEntity(context: context)
                newBook.title = book.title
                newBook.author = book.author
                newBook.isbn = book.isbn
                newBook.publisher = book.publisher
                newBook.cover = book.cover
                newBook.pubDate = book.pubDate
                newBook.bookDescription = book.bookDescription
                newBook.link = book.link
                newBook.createdAt = book.createdAt ?? Date()

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
    func fetchBooks() -> [Book]? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()

        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap { entity in
                // Since Core Data attributes are now optional, we need to verify required fields exist
                guard let title = entity.title,
                      let author = entity.author,
                      let isbn = entity.isbn,
                      let publisher = entity.publisher else {
                    print("Warning: Found book entity with missing required fields")
                    return nil
                }
                
                return Book(
                    title: title,
                    author: author,
                    isbn: isbn,
                    publisher: publisher,
                    cover: entity.cover,
                    pubDate: entity.pubDate,
                    bookDescription: entity.bookDescription,
                    link: entity.link,
                    createdAt: entity.createdAt,
                    tags: convertTagEntitiesToModels(entity.tags)
                )
            }
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
        
        fetchRequest.predicate = NSPredicate(format: "isbn == %@", isbn)
        
        do {
            let books = try context.fetch(fetchRequest)
            
            if let bookToDelete = books.first {
                context.delete(bookToDelete)
                
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
    
    // MARK: - Tag
    // Helper method to convert TagEntity Set to [Tag]
    private func convertTagEntitiesToModels(_ tagEntities: NSSet?) -> [Tag]? {
        // If tagEntities is nil, return nil
        guard let tagEntities = tagEntities else { return nil }
        
        // Convert the NSSet to an array of TagEntity objects
        let tagEntityArray = tagEntities.allObjects as? [TagEntity] ?? []
        
        // Map TagEntity objects to Tag models
        let tags = tagEntityArray.map { tagEntity in
            Tag(
                id: tagEntity.id ?? UUID(),
                name: tagEntity.name ?? "",
                createdAt: tagEntity.createdAt ?? Date()
            )
        }
        
        // If the resulting array is empty, return nil. Otherwise, return the array
        return tags.isEmpty ? nil : tags
    }
    
}

extension CoreDataManager {
    
    // MARK: - Tag Operations
    
    func fetchTags() -> [Tag]? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap { entity in
                guard let id = entity.id,
                      let name = entity.name else { return nil }
                
                return Tag(
                    id: id,
                    name: name,
                    createdAt: entity.createdAt ?? Date()
                )
            }
        } catch {
            print("Failed to fetch tags: \(error.localizedDescription)")
            return nil
        }
    }
    
    func saveTag(tag: Tag) {
        let context = persistentContainer.viewContext
        let newTag = TagEntity(context: context)
        newTag.id = tag.id
        newTag.name = tag.name
        newTag.createdAt = tag.createdAt
        
        do {
            try context.save()
            print("Tag saved successfully")
        } catch {
            print("Failed to save tag: \(error.localizedDescription)")
        }
    }
    
    func deleteTag(with id: UUID) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let tags = try context.fetch(fetchRequest)
            if let tagToDelete = tags.first {
                context.delete(tagToDelete)
                try context.save()
                print("Tag deleted successfully")
            }
        } catch {
            print("Failed to delete tag: \(error.localizedDescription)")
        }
    }
    
    func updateTag(id: UUID, newName: String) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let tags = try context.fetch(fetchRequest)
            if let tagToUpdate = tags.first {
                tagToUpdate.name = newName
                try context.save()
                print("Tag updated successfully")
            }
        } catch {
            print("Failed to update tag: \(error.localizedDescription)")
        }
    }
    
    func assignTag(tagId: UUID, toBook bookISBN: String) {
        let context = persistentContainer.viewContext
        
        // Fetch tag and book
        let tagFetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
        tagFetchRequest.predicate = NSPredicate(format: "id == %@", tagId as CVarArg)
        
        let bookFetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        bookFetchRequest.predicate = NSPredicate(format: "isbn == %@", bookISBN)
        
        do {
            let tags = try context.fetch(tagFetchRequest)
            let books = try context.fetch(bookFetchRequest)
            
            if let tag = tags.first, let book = books.first {
                book.addToTags(tag)
                try context.save()
                print("Tag assigned successfully")
            }
        } catch {
            print("Failed to assign tag: \(error.localizedDescription)")
        }
    }
    
    func removeTag(tagId: UUID, fromBook bookISBN: String) {
        let context = persistentContainer.viewContext
        
        let tagFetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
        tagFetchRequest.predicate = NSPredicate(format: "id == %@", tagId as CVarArg)
        
        let bookFetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        bookFetchRequest.predicate = NSPredicate(format: "isbn == %@", bookISBN)
        
        do {
            let tags = try context.fetch(tagFetchRequest)
            let books = try context.fetch(bookFetchRequest)
            
            if let tag = tags.first, let book = books.first {
                book.removeFromTags(tag)
                try context.save()
                print("Tag removed successfully")
            }
        } catch {
            print("Failed to remove tag: \(error.localizedDescription)")
        }
    }
}

// MARK: - BookEntity Extension
extension BookEntity {
    func toBook() -> Book {
        return Book(
            title: self.title ?? "",
            author: self.author ?? "",
            isbn: self.isbn ?? "",
            publisher: self.publisher ?? "",
            cover: self.cover,
            pubDate: self.pubDate,
            bookDescription: self.bookDescription,
            link: self.link,
            createdAt: self.createdAt,
            tags: self.tags?.allObjects.compactMap { tagEntity in
                guard let tagEntity = tagEntity as? TagEntity,
                      let id = tagEntity.id,
                      let name = tagEntity.name else {
                    return nil
                }
                return Tag(
                    id: id,
                    name: name,
                    createdAt: tagEntity.createdAt ?? Date()
                )
            }
        )
    }
}

// MARK: - CloudKit

extension CoreDataManager {
    func handleSyncConflicts() {
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(managedObjectContextDidSave),
            name: NSNotification.Name.NSManagedObjectContextDidSave,
            object: nil
        )
    }
    
    @objc private func managedObjectContextDidSave(_ notification: Notification) {
        persistentContainer.viewContext.perform {
            self.persistentContainer.viewContext.mergeChanges(fromContextDidSave: notification)
        }
    }
}
