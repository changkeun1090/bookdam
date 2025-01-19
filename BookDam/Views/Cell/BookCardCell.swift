//
//  BookCell.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/3/25.
//

import UIKit

class BookCardCell: UICollectionViewCell {
    
    static let identifier = "BookCardCell"        
    
    private var book: Book?
    
    let imageShadowView: UIView = {
        let aView = UIView()
        aView.layer.shadowOffset = CGSize(width: 2, height: 2)
        aView.layer.shadowOpacity = 0.3
        aView.layer.shadowRadius = 10
        aView.layer.shadowColor = UIColor.gray.cgColor
        aView.translatesAutoresizingMaskIntoConstraints = false
        return aView
    }()
    
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 8.0
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let selectionIndicator: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle")
        imageView.tintColor = Constants.Colors.accent // Using your app's accent color
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true // Hidden by default
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageShadowView)
        imageShadowView.addSubview(coverImageView)
        
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coverImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // Add the selection indicator to the cell's content view
        contentView.addSubview(selectionIndicator)
        
        // Add constraints for the selection indicator
        NSLayoutConstraint.activate([
            selectionIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionIndicator.widthAnchor.constraint(equalToConstant: 24),
            selectionIndicator.heightAnchor.constraint(equalToConstant: 24)
        ])
   

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with book: Book) {
        
        if let coverURL = book.cover {
            loadCoverImage(from: coverURL)
        }
    }

    private func loadCoverImage(from urlString: String) {
        NetworkManager.shared.fetchImage(from: urlString) { [weak self] image in
            guard let self = self, let image = image else {
                print("Failed to load cover image: \(urlString)")
                return
            }
            
            DispatchQueue.main.async {
                self.coverImageView.image = image
            }
        }
    }
    
    // Add these methods to handle selection state
    func showSelectionIndicator(selected: Bool = false) {
        selectionIndicator.isHidden = false
        updateSelectionState(selected)
    }
    
    func hideSelectionIndicator() {
        selectionIndicator.isHidden = true
        // Make sure to clear any selection-related styling
        coverImageView.layer.borderWidth = 0
        coverImageView.layer.borderColor = nil
    }
    
    func updateSelectionState(_ selected: Bool) {
        
        print("CARD CELL: ", selected)
        
        if selected {
            selectionIndicator.image = UIImage(systemName: "checkmark.circle.fill")
            coverImageView.layer.borderColor = Constants.Colors.accent.cgColor
            coverImageView.layer.borderWidth = 1
        } else {
            selectionIndicator.image = UIImage(systemName: "circle")
            coverImageView.layer.borderWidth = 0
        }
    }

}
