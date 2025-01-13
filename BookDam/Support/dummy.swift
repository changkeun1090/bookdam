class BooksVC: UIViewController {
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.Layout.layoutMargin
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private func setupUI() {
        view.addSubview(containerStackView)
        
        // Add horizontalStackView and bookCardCollectionVC.view to containerStackView
        containerStackView.addArrangedSubview(horizontalStackView)
        containerStackView.addArrangedSubview(bookCardCollectionVC.view)
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            horizontalStackView.heightAnchor.constraint(equalToConstant: Layout.stackViewHeight)
        ])
    }
    
    private func updateLayoutForSearchState() {
        if isSearching {
            horizontalStackView.isHidden = true
        } else {
            horizontalStackView.isHidden = false
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
