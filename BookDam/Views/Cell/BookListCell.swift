//
//  BookListCell.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/7/25.
//

import UIKit

class BookListCell: UITableViewCell {
    
    let imageShadowView: UIView = {
        let aView = UIView()
        aView.layer.shadowOffset = CGSize(width: 2, height: 2)
        aView.layer.shadowOpacity = 0.3
        aView.layer.shadowRadius = 10
        aView.layer.shadowColor = UIColor.gray.cgColor
        aView.translatesAutoresizingMaskIntoConstraints = false
        return aView
    }()
    
    // UI Elements
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private let mainTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.Fonts.bodyBold
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byCharWrapping
        label.font = Constants.Fonts.smallBody
        label.textColor = Constants.Colors.subText
        return label
    }()
    
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.smallBody
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
    
    private lazy var authorPublisherStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [authorLabel, publisherLabel])
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        authorLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        publisherLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        return stackView
    }()
    

    // Add the image view and labels to the content view of the cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = Constants.Colors.mainBackground
        contentView.addSubview(imageShadowView)
        imageShadowView.addSubview(coverImageView)
        
        contentView.addSubview(mainTitleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(authorPublisherStackView)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
                
        let (imageWidth, imageHeight) = Constants.BookImageSize.calculate(type: .card)
        
        NSLayoutConstraint.activate([
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.layoutMargin),
            coverImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            coverImageView.widthAnchor.constraint(equalToConstant: imageWidth),
            coverImageView.heightAnchor.constraint(equalToConstant: imageHeight)
        ])
        
        NSLayoutConstraint.activate([
            mainTitleLabel.topAnchor.constraint(equalTo: coverImageView.topAnchor, constant: Constants.Layout.layoutMargin),
            mainTitleLabel.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: Constants.Layout.gutter),
            mainTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.layoutMargin)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: Constants.Layout.extraSmMargin),
            subTitleLabel.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: Constants.Layout.gutter),
            subTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.layoutMargin)
        ])
        
        NSLayoutConstraint.activate([
            authorPublisherStackView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: Constants.Layout.layoutMargin),
            authorPublisherStackView.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: Constants.Layout.gutter),
            authorPublisherStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.layoutMargin),
        ])

    }
    
    func configure(with book: Book) {
        configureTitles(from: book.title)
        configureMetadata(author: book.author, publisher: book.publisher)
        
        if let coverURL = book.cover {
            loadCoverImage(from: coverURL)
        }
    }

    private func configureTitles(from title: String) {
        mainTitleLabel.text = title.onlyMainTitle()
        subTitleLabel.text = title.onlySubTitle()
    }

    private func configureMetadata(author: String, publisher: String) {
        authorLabel.text = author.formatAuthors()
        publisherLabel.text = publisher.formatForHorizontalStackView()
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
}

