//
//  QuotesView.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/6/25.
//

import UIKit

class QuotesView: UIView {
    
    
    var quoteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GowunDodum-Regular", size: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GowunDodum-Regular", size: 16)
        label.textColor = Constants.Colors.subText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        getRandomQuotes()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        addSubview(quoteLabel)
        addSubview(authorLabel)
        
        quoteLabel.addInterlineSpacing(spacingValue: 8)
        quoteLabel.textAlignment = .center
        quoteLabel.lineBreakStrategy = .hangulWordPriority
        
        NSLayoutConstraint.activate([
            quoteLabel.topAnchor.constraint(equalTo: topAnchor),
            quoteLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            quoteLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Layout.layoutMargin*3),
            quoteLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Layout.layoutMargin*3)
        ])
                
        NSLayoutConstraint.activate([
            authorLabel.topAnchor.constraint(equalTo: quoteLabel.bottomAnchor, constant: Constants.Layout.layoutMargin*2),
            authorLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            authorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Layout.layoutMargin),
            authorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Layout.layoutMargin),
        ])
        
    }
    
    func getRandomQuotes() {
        if let randomQuote = bookQuotes.randomElement() {
            quoteLabel.text = randomQuote.quote
            authorLabel.text = randomQuote.author
        }
    }
}


