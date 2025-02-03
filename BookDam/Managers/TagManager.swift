//
//  TagManager.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/15/25.
//

import Foundation
import CoreData

protocol TagManagerDelegate: AnyObject {
    func tagManager(_ manager: TagManager, didUpdateTags tags: [Tag])
    func tagManager(_ manager: TagManager, didDeleteTags ids: Set<UUID>)
}

enum TagCreationResult {
    case success
    case duplicateExists
    case invalid
}

class TagManager {
    
    // MARK: - Properties
    static let shared = TagManager()
    weak var delegate: TagManagerDelegate?
    
    private(set) var tags: [Tag] = []
    
    // MARK: - Initialization
    private init() {
        loadTags()
    }
    
    // MARK: - Public Methods    
    func loadTags() {        
        if let tagEntities = CoreDataManager.shared.fetchTags() {
            self.tags = tagEntities
            delegate?.tagManager(self, didUpdateTags: tags)
        }
    }
    
    func createTag(name: String) -> TagCreationResult {
        // Validate tag name
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return .invalid }
        
        // Check for duplicates
        guard !tags.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) else {
            return .duplicateExists
        }
        
        // Create new tag
        let newTag = Tag(name: trimmedName)
        CoreDataManager.shared.saveTag(tag: newTag)
        loadTags()
        return .success
    }
    
    func deleteTag(with id: UUID) {
        CoreDataManager.shared.deleteTag(with: id)
        loadTags()
    }
    
    func updateTag(id: UUID, newName: String) {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        CoreDataManager.shared.updateTag(id: id, newName: trimmedName)
        loadTags()
    }
    
    func assignTag(tagId: UUID, toBook bookISBN: String) {
        CoreDataManager.shared.assignTag(tagId: tagId, toBook: bookISBN)
        loadTags()
    }
    
    func removeTag(tagId: UUID, fromBook bookISBN: String) {
        CoreDataManager.shared.removeTag(tagId: tagId, fromBook: bookISBN)
        loadTags()
    }
}
