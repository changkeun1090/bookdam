//
//  BookDetailVC.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/7/25.
//

import UIKit

class BookDetailVC: UIViewController {
    
    private var book: Book?
    private var bookLink: String?
    private var isSaved = false
    
    private var selectedTagIds: Set<UUID> = []
    private let tagCellIdentifier = "TagCell"
    
    weak var deletionDelegate: BooksDeletionDelegate?
    
    // MARK: UI - Book Info

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
    
    private let descriptionHeaderLabel: UILabel = {
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
    
    // MARK: UI - Tag
    private let tagContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tagCollectionView: UICollectionView = {
        let layout = LeftAlignedFlowLayout()
        layout.minimumInteritemSpacing = Constants.Layout.smMargin
        layout.minimumLineSpacing = Constants.Layout.smMargin
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
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

        if isSaved {
            let editButton = UIBarButtonItem(title: "편집", style: .plain, target: self, action: #selector(editButtonTapped))
            let deleteButton = UIBarButtonItem(title: "삭제", style: .done, target: self, action: #selector(removeButtonTapped))
            deleteButton.tintColor = Constants.Colors.warning
            
            navigationItem.rightBarButtonItems = [deleteButton, editButton]
        } else {
            let saveButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(saveButtonTapped))
            navigationItem.rightBarButtonItem = saveButton
        }
        
    }
    
    private func setupUI() {
        
        view.addSubview(imageShadowView)
        imageShadowView.addSubview(coverImageView)
        view.addSubview(mainTitleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(subInfoStackView)
        view.addSubview(descriptionHeaderLabel)
        view.addSubview(bookDescriptionLabel)
        view.addSubview(linkLabel)
        view.addSubview(tagContainerView)
        tagContainerView.addSubview(tagCollectionView)
        
        
        tagCollectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: tagCellIdentifier)
        tagCollectionView.delegate = self
        tagCollectionView.dataSource = self
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
            descriptionHeaderLabel.topAnchor.constraint(equalTo: subInfoStackView.bottomAnchor, constant: Constants.Layout.lgMargin),
            descriptionHeaderLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.Layout.layoutMargin),
            descriptionHeaderLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.Layout.layoutMargin),
        ])
        
        NSLayoutConstraint.activate([
            bookDescriptionLabel.topAnchor.constraint(equalTo: descriptionHeaderLabel.bottomAnchor, constant: Constants.Layout.smMargin),
            bookDescriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.Layout.layoutMargin),
            bookDescriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.Layout.layoutMargin),
        ])

        NSLayoutConstraint.activate([
            // Update linkLabel constraint to attach to tagContainerView
            linkLabel.topAnchor.constraint(equalTo: bookDescriptionLabel.bottomAnchor, constant: Constants.Layout.mdMargin),
            linkLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.Layout.layoutMargin),
        ])
                                
        NSLayoutConstraint.activate([
            tagContainerView.topAnchor.constraint(equalTo: linkLabel.bottomAnchor, constant: Constants.Layout.mdMargin),
            tagContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.Layout.layoutMargin),
            tagContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.Layout.layoutMargin),
            
            tagCollectionView.topAnchor.constraint(equalTo: tagContainerView.topAnchor),
            tagCollectionView.leadingAnchor.constraint(equalTo: tagContainerView.leadingAnchor),
            tagCollectionView.trailingAnchor.constraint(equalTo: tagContainerView.trailingAnchor),
            tagCollectionView.heightAnchor.constraint(equalToConstant: 36),
            tagCollectionView.bottomAnchor.constraint(equalTo: tagContainerView.bottomAnchor),
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
        
        showTagManagementSheet()
                
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
        
        tagCollectionView.reloadData()
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
    
    private func showTagManagementSheet() {
        let tagSheet = TagManagementSheet(selectedTagIds: selectedTagIds)
        tagSheet.delegate = self
        present(tagSheet, animated: true)
    }
    
    @objc private func linkLabelTapped() {
        guard let link = bookLink else {return}
        if let url = URL(string: link) {
            presentSafariVC(with: url)
        }
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
    
    @objc private func editButtonTapped() {
        showTagManagementSheet()
    }


}

extension BookDetailVC: TagManagementSheetDelegate {
    func tagManagementSheet(_ sheet: TagManagementSheet, didUpdateSelectedTags tags: Set<UUID>) {
        // Update our local selected tags
        selectedTagIds = tags
    }
    
    func tagManagementSheetDidSave(_ sheet: TagManagementSheet) {
        guard let book = book else {
            print("No book data to save")
            return
        }
        
        // Update CoreData
        CoreDataManager.shared.saveBookWithTags(book: book, tagIds: selectedTagIds)
        
        // Refresh book data to show updated tags
//        if let updatedBook = CoreDataManager.shared.fetchBookByISBN(isbn: book.isbn)?.toBook() {
//            configure(with: updatedBook, isSaved: true)
//        }
        
        sheet.showAutoDismissAlert(title: "저장 완료되었습니다", message: "", duration: 0.5)
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.navigationController?.popViewController(animated: true)
        }

        
//        sheet.dismiss(animated: true)
    }
    
    func tagManagementSheetDidCancel(_ sheet: TagManagementSheet) {
        // If user cancels, we don't need to do anything special
        // The sheet will dismiss itself
    }
}

// MARK: - UICollectionViewDataSource
extension BookDetailVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return book?.tags?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagCellIdentifier, for: indexPath) as? TagCollectionViewCell,
              let tag = book?.tags?[indexPath.item] else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: tag)
        if isSaved {
            cell.isUserInteractionEnabled = true
            
            let interaction = UIContextMenuInteraction(delegate: self)
            cell.interactions.forEach { if $0 is UIContextMenuInteraction { cell.removeInteraction($0) } }
            cell.addInteraction(interaction)
            
            cell.tagId = tag.id
        } else {
            cell.isUserInteractionEnabled = false
        }
        return cell
    }
}

// MARK: - UIContextMenuInteractionDelegate
extension BookDetailVC: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        // Get the point in collection view's coordinate space
        let locationInCollectionView = interaction.location(in: tagCollectionView)
        
        // Get the index path for the cell at this location
        guard let indexPath = tagCollectionView.indexPathForItem(at: locationInCollectionView),
              let cell = tagCollectionView.cellForItem(at: indexPath) as? TagCollectionViewCell,
              let tagId = cell.tagId,
              let tag = book?.tags?.first(where: { $0.id == tagId }) else {
            return nil
        }
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { _ in
            // Create menu actions
            let editAction = UIAction(
                title: "태그 수정",
                image: UIImage(systemName: "pencil")
            ) { [weak self] _ in
                self?.handleTagEdit(tag)
            }
            
            let deleteAction = UIAction(
                title: "태그 삭제",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.handleTagDelete(tag)
            }
            
            return UIMenu(children: [editAction, deleteAction])
        }
    }
    
    private func handleTagEdit(_ tag: Tag) {
        let alert = UIAlertController(title: "태그 수정", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = tag.name
            textField.placeholder = "태그 이름을 입력하세요"
        }
        
        let saveAction = UIAlertAction(title: "저장", style: .default) { [weak self] _ in
            guard let newName = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !newName.isEmpty else { return }
            
            // Update tag
            TagManager.shared.updateTag(id: tag.id, newName: newName)
            
            // Refresh book data to show updated tag
            if let book = self?.book {
                self?.configure(with: book, isSaved: true)
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func handleTagDelete(_ tag: Tag) {
        showConfirmationAlert(
            title: "태그 삭제",
            message: "이 태그를 삭제하시겠습니까?",
            confirmActionTitle: "삭제",
            cancelActionTitle: "취소"
        ) { [weak self] in
            // Delete tag
            TagManager.shared.deleteTag(with: tag.id)
            
            // Refresh book data to show updated tags
            if let book = self?.book {
                self?.configure(with: book, isSaved: true)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension BookDetailVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

//MARK: TEMPORARY!!

