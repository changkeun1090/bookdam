//
//  Tag.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/15/25.
//

// Tag.swift

import Foundation
import UIKit

struct Tag: Codable {
    let id: UUID
    let name: String
    let createdAt: Date
    
    init(id: UUID = UUID(), name: String, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
    }
}
