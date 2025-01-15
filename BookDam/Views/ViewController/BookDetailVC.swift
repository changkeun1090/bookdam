//
//  BookDetailVC.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/7/25.
//

import UIKit

class BookDetailVC: UIViewController {
    
    var book: Book? 
    var bookLink: String?
    var isSaved = false
    
    private var selectedTagIds: Set<UUID> = []

    weak var deletionDelegate: BooksDeletionDelegate?

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
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private let mainTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakStrategy = .hangulWordPriority
        label.font = Constants.Fonts.largeBodyBold
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakStrategy = .hangulWordPriority
        label.font = Constants.Fonts.body
        label.textColor = Constants.Colors.subText
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
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.bodyBold
        label.text = "책소개"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bookDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.smallBody
        label.textColor = Constants.Colors.subText
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let linkLabel: UILabel = {
        let label = UILabel()
        let text = "자세히보기"
        label.font = Constants.Fonts.smallBody
        label.textColor = Constants.Colors.subText
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let attributeString = NSMutableAttributedString(string: text)
        attributeString.addAttribute(.underlineStyle , value: 1, range: NSRange.init(location: 0, length: text.count))
        label.attributedText = attributeString
        
        return label
    }()
    
    private lazy var subInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [authorLabel, publisherLabel, pubDateLabel])
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        authorLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        publisherLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        pubDateLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        return stackView
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Constants.Colors.mainBackground
        
        setupNavigationBar()
        setupUI()
        addTapGestureToLinkLabel()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = .none
        
        let backButton = UIBarButtonItem()
        
        navigationController?.navigationBar.tintColor = Constants.Colors.accent
        backButton.title = "돌아가기"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let deleteButton = UIBarButtonItem(title: "삭제", style: .done, target: self, action: #selector(removeButtonTapped))
        deleteButton.tintColor = Constants.Colors.warning
        let saveButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(saveButtonTapped))
        saveButton.tintColor = nil
        
        navigationItem.rightBarButtonItem  = isSaved ? deleteButton:saveButton
        
    }
    
    private func setupUI() {
        
        view.addSubview(imageShadowView)
        imageShadowView.addSubview(coverImageView)
        view.addSubview(mainTitleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(subInfoStackView)
        view.addSubview(headerLabel)
        view.addSubview(bookDescriptionLabel)
        view.addSubview(linkLabel)
        
        let (imageWidth, imageHeight) = Constants.Size.calculateImageSize(itemCount: 2)
        
        
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Layout.layoutMargin),
            coverImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: imageHeight),
            coverImageView.widthAnchor.constraint(equalToConstant: imageWidth)
        ])
        
        NSLayoutConstraint.activate([
            mainTitleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: Constants.Layout.lgMargin),
            mainTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.Layout.layoutMargin),
            mainTitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.Layout.layoutMargin),
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: Constants.Layout.smMargin),
            subTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.Layout.layoutMargin),
            subTitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.Layout.layoutMargin),
        ])
        
        NSLayoutConstraint.activate([
            subInfoStackView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: Constants.Layout.mdMargin),
            subInfoStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.Layout.layoutMargin),
            subInfoStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.Layout.layoutMargin),
        ])
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: subInfoStackView.bottomAnchor, constant: Constants.Layout.lgMargin),
            headerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.Layout.layoutMargin),
            headerLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.Layout.layoutMargin),
        ])
        
        NSLayoutConstraint.activate([
            bookDescriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: Constants.Layout.smMargin),
            bookDescriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.Layout.layoutMargin),
            bookDescriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.Layout.layoutMargin),
        ])
        
        NSLayoutConstraint.activate([
            linkLabel.topAnchor.constraint(equalTo: bookDescriptionLabel.bottomAnchor, constant: Constants.Layout.mdMargin),
            linkLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.Layout.layoutMargin),
        ])
        

    }
    
    @objc private func saveButtonTapped() {
        guard let book = book else {
            print("No book data to save")
            return
        }
        
        if CoreDataManager.shared.isBookExist(isbn: book.isbn) {
            self.showInfoAlert(title: "이미 저장된 책입니다", message: "", buttonTitle: "확인")
            return
        }

//        CoreDataManager.shared.saveBook(book: book)
//        self.showAutoDismissAlert(title: "저장 완료되었습니다", message: "", duration: 0.5)
//                
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.navigationController?.popViewController(animated: true)
//        }
        
        showTagManagementSheet()
                
    }
    
    @objc private func removeButtonTapped() {
        
        guard let book = book else {
            print("No book data to save")
            return
        }
        
        self.showConfirmationAlert(title: "정말 삭제하시겠습니까?", message: "", confirmActionTitle: "삭제", cancelActionTitle: "취소") {
            CoreDataManager.shared.deleteBookwithIsbn(by: book.isbn)
            self.deletionDelegate?.didDeleteBook(withIsbn: book.isbn)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    
    func configure(with book: Book, isSaved: Bool = false) {
        self.book = book
        configureTitles(from: book.title)
        configureMetadata(author: book.author, publisher: book.publisher)
        configureOptionalFields(book)
        bookLink = book.link
        self.isSaved = isSaved
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

    private func configureOptionalFields(_ book: Book) {
        
        if let pubDate = book.pubDate {
            pubDateLabel.text = pubDate.formattedDate()?.formatForHorizontalStackView()
        } else {
            pubDateLabel.text = ""
        }
                
        if let description = book.bookDescription {
            bookDescriptionLabel.text = description.decodedHTML()
        } else {
            bookDescriptionLabel.text = ""
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
 
    private func addTapGestureToLinkLabel() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(linkLabelTapped))
        linkLabel.isUserInteractionEnabled = true
        linkLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func linkLabelTapped() {
        guard let link = bookLink else {return}
        if let url = URL(string: link) {
            presentSafariVC(with: url)
        }
    }
    
    private func showTagManagementSheet() {
        let tagSheet = TagManagementSheet(selectedTagIds: selectedTagIds)
        tagSheet.delegate = self
        present(tagSheet, animated: true)
    }

}

extension BookDetailVC: TagManagementSheetDelegate {
    func tagManagementSheet(_ sheet: TagManagementSheet, didUpdateSelectedTags tags: Set<UUID>) {
        // Update our local selected tags
        selectedTagIds = tags
    }
    
    func tagManagementSheetDidSave(_ sheet: TagManagementSheet) {
        // Save the book with selected tags
        guard let book = book else {
            print("No book data to save")
            return
        }
        
        // First save the book
        CoreDataManager.shared.saveBook(book: book)
        
        // Then assign all selected tags
        for tagId in selectedTagIds {
            CoreDataManager.shared.assignTag(tagId: tagId, toBook: book.isbn)
        }
        
        // Show success message and dismiss
        self.showAutoDismissAlert(title: "저장 완료되었습니다", message: "", duration: 0.5)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func tagManagementSheetDidCancel(_ sheet: TagManagementSheet) {
        // If user cancels, we don't need to do anything special
        // The sheet will dismiss itself
    }
}
