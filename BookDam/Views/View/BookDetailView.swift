//
//  BookDetailCardView.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/7/25.
//

import UIKit

class BookDetailView: UIView {
    
    // UI Elements
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 15
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.bodyBold
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakStrategy = .hangulWordPriority
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.smallBody
        label.numberOfLines = 1
        label.textColor = Constants.Colors.subText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let publisherLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.smallBody
        label.textColor = Constants.Colors.subText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pubDateLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.smallBody
        label.textColor = Constants.Colors.subText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var publisherPubDateStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [publisherLabel, pubDateLabel])
        stackView.axis = .horizontal // Stack vertically
        stackView.spacing = Constants.Layout.smMargin // Adjust the spacing between the labels
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(coverImageView)
        addSubview(titleLabel)
//        addSubview(publisherLabel)
//        addSubview(pubDateLabel)
//        addSubview(publisherPubDateStackView)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
                
        let (imageWidth, imageHeight) = Constants.Size.calculateImageSize(itemCount: 2)
        
        // Constraints for cover image
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.Layout.layoutMargin),
            coverImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Layout.layoutMargin),
            coverImageView.widthAnchor.constraint(equalToConstant: imageWidth),
            coverImageView.heightAnchor.constraint(equalToConstant: imageHeight)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: coverImageView.topAnchor, constant: Constants.Layout.layoutMargin),
            titleLabel.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: Constants.Layout.gutter),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Layout.layoutMargin)
        ])
        
     
    }
    
    func configure(with book: Book) {

        titleLabel.text = book.title.removeSubtitle()
        authorLabel.text = book.author.formatAuthors()
        publisherLabel.text = book.publisher
        pubDateLabel.text = book.pubDate
        
        // Load the cover image asynchronously (use a library like SDWebImage for caching)        
        if let link = book.link {
            ImageFetcher.fetchCoverImageUrl(from: link) { coverImageUrl in
                guard let coverImageUrl = coverImageUrl else {
                    print("No cover image found")
                    return
                }
                
                // Download the image from the URL
                if let url = URL(string: coverImageUrl) {
                    URLSession.shared.dataTask(with: url) { data, response, error in
                        if let data = data, error == nil {
                            DispatchQueue.main.async {
                                self.coverImageView.image = UIImage(data: data)
                            }
                        }
                    }.resume()
                }
            }
        }
        
    }
    
}
