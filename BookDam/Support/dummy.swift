private func enterSelectMode() {
    isSelectMode = true
    
    // First, create the cancel button
    let cancelButton = IconButton(title: "취소", image: nil, action: #selector(cancelButtonTapped))
    
    // Important: Add the cancel button BEFORE hiding other views
    horizontalStackView.insertArrangedSubview(cancelButton, at: 0)
    
    // Now update the visibility of other buttons
    tagButton.removeFromSuperview() // Remove instead of hiding
    moreButton.removeFromSuperview() // Remove instead of hiding
    
    // Tell the collection view to enter select mode
    bookCardCollectionVC.enterSelectMode()
}

private func exitSelectMode() {
    isSelectMode = false
    
    // Remove the cancel button
    horizontalStackView.arrangedSubviews.first?.removeFromSuperview()
    
    // Restore original buttons
    horizontalStackView.insertArrangedSubview(tagButton, at: 0)
    rightStackView.addArrangedSubview(moreButton)
    
    // Tell collection view to exit select mode
    bookCardCollectionVC.exitSelectMode()
}
