func tagManagementSheetDidSave(_ sheet: TagManagementSheet) {
    guard let currentBook = book else {
        print("No book data to save")
        return
    }
    
    // First update CoreData
    CoreDataManager.shared.updateBookWithTags(book: currentBook, tagIds: selectedTagIds)
    
    // Fetch the updated book from CoreData to get the new tag relationships
    if let updatedBook = CoreDataManager.shared.fetchBookByISBN(isbn: currentBook.isbn)?.toBook() {
        // Update our local book property with the fresh data
        self.book = updatedBook
        
        DispatchQueue.main.async {
            sheet.showAutoDismissAlert(title: "저장 완료되었습니다", message: "", duration: 0.5)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                sheet.dismiss(animated: true) {
                    // Now reload with the updated data
                    self.tagCollectionView.reloadData()
                }
            }
        }
    }
}
