//
//  String+Ext.swift
//  BookDam
//
//  Created by ChangKeun Ji on 1/7/25.
//

import UIKit

extension String {
    // This function splits the string based on the "-" and returns an attributed string
    func toAttributedTitle(mainFont: UIFont, subFont: UIFont, subTextColor: UIColor) -> NSAttributedString {
        // Split the title into main title and subtitle
        let parts = self.split(separator: "-").map { String($0).trimmingCharacters(in: .whitespaces) }
        
        // Initialize an attributed string
        let attributedString = NSMutableAttributedString()
        
        if parts.count > 1 {
            // Add the main title with main font
            let mainTitle = parts[0]
            let mainTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: mainFont
            ]
            let mainTitleAttributed = NSAttributedString(string: mainTitle, attributes: mainTitleAttributes)
            attributedString.append(mainTitleAttributed)
            
            // Add the subtitle with a different font and color
            let subtitle = parts[1]
            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: subFont,
                .foregroundColor: subTextColor
            ]
            let subtitleAttributed = NSAttributedString(string:" - \(subtitle)", attributes: subtitleAttributes)
            attributedString.append(subtitleAttributed)
        } else {
            // If there's no subtitle, return just the main title with main font
            let mainTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: mainFont
            ]
            let mainTitleAttributed = NSAttributedString(string: self, attributes: mainTitleAttributes)
            attributedString.append(mainTitleAttributed)
        }
        
        return attributedString
    }
    // This function splits the string based on the "-" and returns an attributed string
    func toAttributedTitleNextLine(mainFont: UIFont, subFont: UIFont, subTextColor: UIColor) -> NSAttributedString {
        // Split the title into main title and subtitle
        let parts = self.split(separator: "-").map { String($0).trimmingCharacters(in: .whitespaces) }
        
        // Initialize an attributed string
        let attributedString = NSMutableAttributedString()
        
        if parts.count > 1 {
            // Add the main title with main font
            let mainTitle = parts[0]
            let mainTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: mainFont
            ]
            let mainTitleAttributed = NSAttributedString(string: mainTitle, attributes: mainTitleAttributes)
            attributedString.append(mainTitleAttributed)
            
            // Add a line break before the subtitle
            attributedString.append(NSAttributedString(string: "\n"))
            
            // Add the subtitle with a different font and color
            let subtitle = parts[1]
            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: subFont,
                .foregroundColor: subTextColor
            ]
            let subtitleAttributed = NSAttributedString(string: subtitle, attributes: subtitleAttributes)
            attributedString.append(subtitleAttributed)
        } else {
            // If there's no subtitle, return just the main title with main font
            let mainTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: mainFont
            ]
            let mainTitleAttributed = NSAttributedString(string: self, attributes: mainTitleAttributes)
            attributedString.append(mainTitleAttributed)
        }
        
        return attributedString
    }
    
    func toAttributedTitleWithSpacing(mainFont: UIFont, subFont: UIFont, subTextColor: UIColor, lineSpacing: CGFloat = 6) -> NSAttributedString {
        // Split the title into main title and subtitle
        let parts = self.split(separator: "-").map { String($0).trimmingCharacters(in: .whitespaces) }
        
        // Initialize an attributed string
        let attributedString = NSMutableAttributedString()
        
        if parts.count > 1 {
            // Add the main title with main font
            let mainTitle = parts[0]
            let mainTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: mainFont
            ]
            let mainTitleAttributed = NSAttributedString(string: mainTitle, attributes: mainTitleAttributes)
            attributedString.append(mainTitleAttributed)
            
            // Add a line break before the subtitle with additional line spacing
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing  // Add spacing between main and subtitle
            let lineBreakAttributed = NSAttributedString(string: "\n", attributes: [
                .paragraphStyle: paragraphStyle
            ])
            attributedString.append(lineBreakAttributed)
            
            // Add the subtitle with a different font and color
            let subtitle = parts[1]
            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: subFont,
                .foregroundColor: subTextColor
            ]
            let subtitleAttributed = NSAttributedString(string: subtitle, attributes: subtitleAttributes)
            attributedString.append(subtitleAttributed)
        } else {
            // If there's no subtitle, return just the main title with main font
            let mainTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: mainFont
            ]
            let mainTitleAttributed = NSAttributedString(string: self, attributes: mainTitleAttributes)
            attributedString.append(mainTitleAttributed)
        }
        
        return attributedString
    }


    
    func removeSubtitle() -> String {
            // Split the string at the first "-" and return the part before it
            let parts = self.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: false)
            return String(parts[0]).trimmingCharacters(in: .whitespaces) // Return the main title part
        }
    
    func formatAuthors() -> String {
        // Split the author string by commas
        let authors = self.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
        
        // Remove parentheses and content within them for all authors
        let cleanedAuthors = authors.map {
            $0.replacingOccurrences(of: "\\(.*?\\)", with: "", options: .regularExpression).trimmingCharacters(in: .whitespaces)
        }
        
        // If there's only one author, return the cleaned author without parentheses
        if cleanedAuthors.count == 1 {
            return cleanedAuthors.first ?? ""
        }
        
        // Get the first author's name
        let firstAuthor = cleanedAuthors.first ?? ""
        
        // Count the number of additional authors (excluding the first)
        let additionalAuthorsCount = cleanedAuthors.count - 1
        
        // Construct the result string
//        return "\(firstAuthor) 외 \(additionalAuthorsCount)명"
        return "\(firstAuthor)"
    }
    
    // Format the pubDate by adding a leading "| " separator
    func formatForHorizontalStackView() -> String {
        return " | \(self)"
    }

    func decodedHTML() -> String {
        guard let data = self.data(using: .utf8) else { return self }
        
        // Create an NSAttributedString with the HTML data
        if let decodedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil
        ) {
            return decodedString.string // Return the decoded string
        }
        
        return self // Return the original string if decoding fails
    }
    
    func formattedDate() -> String? {
        // Step 1: Convert the string to a Date object
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Original format of the string

        if let date = dateFormatter.date(from: self) {
            // Step 2: Format the Date object to the desired format
            dateFormatter.dateFormat = "yyyy.MM.dd" // Desired format
            return dateFormatter.string(from: date)
        }
        return nil // Return nil if the string couldn't be converted to a date
    }
    
    func onlyMainTitle() -> String? {
        let parts = self.split { $0 == "-" || $0 == ":" }.map { String($0).trimmingCharacters(in: .whitespaces) }
        return parts.first ?? self
    }
    
    func onlySubTitle() -> String? {
        let parts = self.split { $0 == "-" || $0 == ":" }.map { String($0).trimmingCharacters(in: .whitespaces) }
        if parts.count > 1 {
            return parts.last
        } else {
            return nil
        }
    }
    
}
