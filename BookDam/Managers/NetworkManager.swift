//
//  NetworkManager.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/5/25.
//

import UIKit

import Foundation
import SwiftSoup

class NetworkManager {
    
    static let shared = NetworkManager()
    private let session = URLSession.shared
    let baseUrl = "http://www.aladin.co.kr/ttb/api/ItemSearch.aspx?"
    private let imageCache = NSCache<NSString, UIImage>()
    
    private init() {
            imageCache.countLimit = 100 // Limit the number of cached images
            imageCache.totalCostLimit = 10 * 1024 * 1024 // Limit cache size (10 MB)
    }
        
    
    
    func searchBooks(query: String, page: String = "1", completion: @escaping (Result<[Book], Error>) -> Void) {
        
        guard let url = buildURL(query: query, page: page) else {
            print("URL Error")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("TASK Error")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("DATA Error")
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let decodedResponse = try decoder.decode(BookSearchResponse.self, from: data)
                completion(.success(decodedResponse.item))
                
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
        }
            task.resume()
    }
            
    // Fetch image from URL with caching
    func fetchImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        
        imageCache.countLimit = 100 // Limit the number of cached images
        imageCache.totalCostLimit = 10 * 1024 * 1024 // Limit cache size (10 MB in this case)

        
        // Check if the image is already in the cache
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        // If not cached, download the image
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching image: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to convert data to image")
                completion(nil)
                return
            }
            
            // Cache the image
            self.imageCache.setObject(image, forKey: urlString as NSString)
            
            // Return the image
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    
    private func buildURL(query: String, page: String) -> URL? {
        var urlComponents = URLComponents(string: baseUrl)
        urlComponents?.queryItems = [
            URLQueryItem(name: "ttbkey", value: "ttbckdrmsdk170515001"),
            URLQueryItem(name: "Query", value: query),
            URLQueryItem(name: "QueryType", value:"Keyword"),
            URLQueryItem(name: "MaxResults", value:"20"),
            URLQueryItem(name: "start", value:page),
            URLQueryItem(name: "SearchTarget", value:"Book"),
            URLQueryItem(name: "Cover", value:"Big"),
            URLQueryItem(name: "output", value:"js"),
            URLQueryItem(name: "Version", value:"20131101"),
        ]
        return urlComponents?.url
    }

}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

/*
func fetchCoverImageUrl(from bookLink: String, completion: @escaping (String?) -> Void) {
    
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
 }*/
