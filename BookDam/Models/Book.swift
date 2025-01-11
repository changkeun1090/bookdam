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
    
    private enum CodingKeys: String, CodingKey {
        case bookDescription = "description"
        case title, author, isbn, publisher, cover, pubDate, link
    }
}

struct BookSearchResponse: Decodable {
    let totalResults: Int
    var item: [Book]
}


