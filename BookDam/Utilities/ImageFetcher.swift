//
//  Helper.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/7/25.
//

import UIKit
import Foundation
import SwiftSoup

class ImageFetcher {

    static func fetchCoverImageUrl(from bookLink: String, completion: @escaping (String?) -> Void) {
   
        guard let bookUrl = URL(string: bookLink) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: bookUrl) { (data, response, error) in
            if let error = error {
                print("Error fetching page: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data found")
                completion(nil)
                return
            }
            
            do {
                let document = try SwiftSoup.parse(String(data: data, encoding: .utf8) ?? "")
                let coverImageUrl = try document.select("meta[property=og:image]").attr("content")
                
                if !coverImageUrl.isEmpty {
                    completion(coverImageUrl)
                } else {
                    print("Cover image not found")
                    completion(nil)
                }
            } catch {
                print("Error parsing HTML: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
