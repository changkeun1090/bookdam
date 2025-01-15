//
//  Book.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/3/25.
//
//

import Foundation
import UIKit

struct Book: Decodable {
    let title: String
    let author: String
    let isbn: String
    let publisher: String
    
    let cover: String?
    let pubDate: String?
    let bookDescription: String?
    let link: String?
    let createdAt: Date?
    let tags: [Tag]?

    private enum CodingKeys: String, CodingKey {
        case bookDescription = "description"
        case title, author, isbn, publisher, cover, pubDate, link, createdAt, tags
    }
    
    init(title: String, author: String, isbn: String, publisher: String,
          cover: String? = nil, pubDate: String? = nil,
          bookDescription: String? = nil, link: String? = nil,
          createdAt: Date? = nil, tags: [Tag]? = nil) {
         self.title = title
         self.author = author
         self.isbn = isbn
         self.publisher = publisher
         self.cover = cover
         self.pubDate = pubDate
         self.bookDescription = bookDescription
         self.link = link
         self.createdAt = createdAt
         self.tags = tags
     }
}

struct BookSearchResponse: Decodable {
    let totalResults: Int
    var item: [Book]
}


