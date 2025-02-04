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
    
    weak var delegate: BooksVCDelegate?
    
    private var tagCollectionViewHeightConstraint: NSLayoutConstraint?
    private var tagContainerMarginBottom: CGFloat {
        return book?.tags?.isEmpty ?? true ? 0 : Constants.Layout.lgMargin
    }
    private var tagContainerBottomConstraint: NSLayoutConstraint?

    // MARK: UI - Container 
        
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false 
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: UI - Book Info

    let imageShadowView: UIView = {
        let view = UIView()
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 10
        view.layer.shadowColor = UIColor.gray.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        label.font = Constants.Fonts.smallBodyBold
        label.numberOfLines = 1
//        label.textColor = Constants.Colors.mainText
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
//        label.textColor = Constants.Colors.mainText
        label.text = "책소개"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bookDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.body
        label.textColor = Constants.Colors.subText
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let linkLabel: UILabel = {
        let label = UILabel()
        let text = "자세히보기 (알라딘)"
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
    
    private lazy var editButton = ButtonFactory.createNavTextButton(title: "편집", style:.accent, target: self , action: #selector(editButtonTapped))

    private lazy var deleteButton = ButtonFactory.createNavTextButton(title: "삭제", style:.warning, target: self , action: #selector(removeButtonTapped))
        
    private lazy var saveButton = ButtonFactory.createNavTextButton(title: "저장", style:.accent, target: self , action: #selector(saveButtonTapped))
    
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
        layout.estimatedItemSize = CGSize(width: 60, height: 32)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear

        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.backgroundColor = Constants.Colors.mainBackground
        
        setupNavigationBar()
        setupCollectionView()
        setupUI()
        
        updateTagContainerBottomConstraint()
        addTapGestureToLinkLabel()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = .none
        if #available(iOS 16.0, *) {
            navigationItem.backAction = UIAction { [weak self] _ in
                self?.backButtonTapped()
            }
        }

        if isSaved {
            let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            spacer.width = Constants.Layout.gutter
            
            navigationItem.rightBarButtonItems = [deleteButton, spacer, editButton]
        } else {
            navigationItem.rightBarButtonItem = saveButton
        }
        
    }
    
    private func setupCollectionView() {
        tagCollectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCell.identifier)
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
    }
    
    private func setupUI() {
                
        scrollView.frame = self.view.bounds
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
                
        contentView.addSubview(imageShadowView)
        imageShadowView.addSubview(coverImageView)
        contentView.addSubview(mainTitleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(subInfoStackView)
                
        contentView.addSubview(tagContainerView)
        tagContainerView.addSubview(tagCollectionView)
                
        contentView.addSubview(descriptionHeaderLabel)
        contentView.addSubview(bookDescriptionLabel)
        contentView.addSubview(linkLabel)
        
        let (imageWidth, imageHeight) = Constants.Size.calculateImageSize(itemCount: 2)

        NSLayoutConstraint.activate([
           scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
           scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
           scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
           scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
           
           contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
           contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
           contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
           contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
           contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
                
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Layout.layoutMargin),
            coverImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: imageHeight),
            coverImageView.widthAnchor.constraint(equalToConstant: imageWidth)
        ])
        
        NSLayoutConstraint.activate([
            mainTitleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: Constants.Layout.lgMargin),
            mainTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.layoutMargin),
            mainTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.layoutMargin),
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: Constants.Layout.smMargin),
            subTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.layoutMargin),
            subTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.layoutMargin),
        ])
        
        NSLayoutConstraint.activate([
            subInfoStackView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: Constants.Layout.layoutMargin),
            subInfoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.layoutMargin),
            subInfoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.layoutMargin),
        ])
        
        NSLayoutConstraint.activate([
            tagContainerView.topAnchor.constraint(equalTo: subInfoStackView.bottomAnchor, constant: Constants.Layout.lgMargin),
            tagContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.layoutMargin),
            tagContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.layoutMargin),
            tagContainerView.bottomAnchor.constraint(equalTo: descriptionHeaderLabel.topAnchor, constant: -tagContainerMarginBottom),

            tagCollectionView.topAnchor.constraint(equalTo: tagContainerView.topAnchor),
            tagCollectionView.leadingAnchor.constraint(equalTo: tagContainerView.leadingAnchor),
            tagCollectionView.trailingAnchor.constraint(equalTo: tagContainerView.trailingAnchor),
            tagCollectionView.bottomAnchor.constraint(equalTo: tagContainerView.bottomAnchor),
        ])
                
        tagCollectionViewHeightConstraint = tagCollectionView.heightAnchor.constraint(equalToConstant: 1000)
        tagCollectionViewHeightConstraint?.isActive = true
                
        NSLayoutConstraint.activate([
            descriptionHeaderLabel.topAnchor.constraint(equalTo: tagContainerView.bottomAnchor, constant: 0),
            descriptionHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.layoutMargin),
            descriptionHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.layoutMargin),
            descriptionHeaderLabel.bottomAnchor.constraint(equalTo: bookDescriptionLabel.topAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            bookDescriptionLabel.topAnchor.constraint(equalTo: descriptionHeaderLabel.bottomAnchor, constant: Constants.Layout.smMargin),
            bookDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.layoutMargin),
            bookDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.layoutMargin),
        ])

        NSLayoutConstraint.activate([
            linkLabel.topAnchor.constraint(equalTo: bookDescriptionLabel.bottomAnchor, constant: Constants.Layout.layoutMargin),
            linkLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.layoutMargin),
            linkLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Layout.gutter)
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
    
    @objc private func backButtonTapped() {
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
            self.delegate?.backToHome()
        }
    }
    
    func configure(with book: Book, isSaved: Bool = false) {
        self.book = book
        self.isSaved = isSaved
        self.selectedTagIds = Set(book.tags?.map { $0.id } ?? [])
        
        configureBookData(book)
        tagCollectionView.reloadData()
        tagCollectionView.layoutIfNeeded()

    }


    private func configureBookData(_ book: Book) {
        mainTitleLabel.text = book.title.onlyMainTitle()
        subTitleLabel.text = book.title.onlySubTitle()
        
        authorLabel.text = book.author.formatAuthors()
        publisherLabel.text = book.publisher.formatForHorizontalStackView()
        
        if let pubDate = book.pubDate {
            pubDateLabel.text = pubDate.formattedDate()?.formatForHorizontalStackView()
        } else {
            pubDateLabel.text = ""
        }
                
        if let description = book.bookDescription {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6
            bookDescriptionLabel.attributedText = NSAttributedString(
                string: description.decodedHTML(),
                attributes: [
                    .paragraphStyle: paragraphStyle,
                    .font: Constants.Fonts.body,
                    .foregroundColor: Constants.Colors.subText
                ]
            )
            
        } else {
            bookDescriptionLabel.text = ""
        }
        
        self.bookLink = book.link
        
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
    
    @objc private func removeButtonTapped() {
        
        guard let book = book else {
            print("No book data to save")
            return
        }
        
        self.showConfirmationAlert(title: "정말 삭제하시겠습니까?", message: "", confirmActionTitle: "삭제", cancelActionTitle: "취소") {
            CoreDataManager.shared.deleteBookwithIsbn(by: book.isbn)
            self.delegate?.didDeleteBook(withIsbn: book.isbn)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc private func editButtonTapped() {
        showTagManagementSheet()
    }
    
    private func showTagManagementSheet() {
        let tagSheet = TagManagementSheet(selectedTagIds: selectedTagIds)
        tagSheet.delegate = self
        present(tagSheet, animated: true)
    }
    
    private func updateCollectionViewHeight(isTagsEmpty: Bool = false) {

        var height: CGFloat = 0
        
        if isTagsEmpty {
            height = 0
        } else {
            height = tagCollectionView.collectionViewLayout.collectionViewContentSize.height
        }
                
        tagCollectionViewHeightConstraint?.constant = height
                        
        view.layoutIfNeeded()
    }
    
    func updateTagContainerBottomConstraint() {
        tagContainerBottomConstraint?.isActive = false
        
        tagContainerBottomConstraint = tagContainerView.bottomAnchor.constraint(
            equalTo: descriptionHeaderLabel.topAnchor,
            constant: -tagContainerMarginBottom
        )
        tagContainerBottomConstraint?.isActive = true
    }
    
    private func updateLayoutForTags() {
        updateTagContainerBottomConstraint()
        view.layoutIfNeeded()
    }
}

// MARK: - TagManagementSheetDelegate

extension BookDetailVC: TagSelectionVCDelegate {
    func tagSelectionVC(_ controller: UIViewController, didUpdateSelectedTags tags: Set<UUID>) {
        selectedTagIds = tags
    }
    
    func tagSelectionVCDidSave(_ sheet: TagManagementSheet) {
        guard let currentBook = book else {
            print("No book data to save")
            return
        }
        
        // 새로운 책 저장
        guard isSaved else {
            CoreDataManager.shared.saveBookWithTags(book: currentBook, tagIds: selectedTagIds)
            didSaveBook(sheet)
            return
        }
        
        // 이미 저장된 책 편집
        CoreDataManager.shared.updateBookWithTags(book: currentBook, tagIds: selectedTagIds)
        if let updatedBook = CoreDataManager.shared.fetchBookByISBN(isbn: currentBook.isbn)?.toBook() {
            self.book = updatedBook
            didSaveBook(sheet, isSaved: true)
            
            
            
        }
        
    }
    
    func tagSelectionVCDidCancel(_ sheet: TagManagementSheet) {
    }
    
    func didSaveBook(_ sheet: TagManagementSheet, isSaved: Bool = false) {
        DispatchQueue.main.async {
            sheet.showAutoDismissAlert(title: "저장 완료되었습니다", message: "", duration: 0.5)
                   
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    sheet.dismiss(animated: true) {
                        self.navigationController?.popToRootViewController(animated: true)
//                        if isSaved {
//                            self.updateLayoutForTags()
//                            self.tagCollectionView.reloadData()
//                        } else {
//                            self.navigationController?.popToRootViewController(animated: true)
//                        }
                    }
                }
        }
    }
    
}

// MARK: - UICollectionViewDataSource

extension BookDetailVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("DATA SOURCE -----------------------", self.book?.tags?.count ?? 0)
        
        guard let tags = book?.tags else {
            updateCollectionViewHeight(isTagsEmpty: true)
            return 0
        }
        
        if tags.isEmpty {
            updateCollectionViewHeight(isTagsEmpty: true)
            return 0
        }
        
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                    
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.identifier, for: indexPath) as? TagCollectionViewCell else {
            return UICollectionViewCell()
        }
                                
        guard let tag = book?.tags?[indexPath.item] else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: tag)        
        
        collectionView.allowsSelection = false
        
        return cell
    }
}

extension BookDetailVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == (book?.tags?.count ?? 0) - 1 {
            updateCollectionViewHeight()
        }
    }
}
