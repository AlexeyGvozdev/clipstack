//
//  ClipItem.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 30.01.2026.
//

import Foundation

/// Represents a single clipboard item
struct ClipItem: Identifiable, Codable, Equatable {
    /// Unique identifier
    let id: UUID
    
    /// The actual content of the clipboard item
    let content: String
    
    /// When the item was copied
    let timestamp: Date
    
    /// The application that was active when copying (optional)
    let sourceApp: String?
    
    /// Type of content
    let contentType: ContentType
    
    /// Preview of the content (first 50 characters)
    var preview: String {
        String(content.prefix(50))
    }
    
    /// Human-readable timestamp
    var formattedTimestamp: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    /// Initialize a new clipboard item
    init(
        id: UUID = UUID(),
        content: String,
        timestamp: Date = Date(),
        sourceApp: String? = nil,
        contentType: ContentType = .plainText
    ) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
        self.sourceApp = sourceApp
        self.contentType = contentType
    }
}

// MARK: - ContentType

extension ClipItem {
    /// Type of clipboard content
    enum ContentType: String, Codable, CaseIterable {
        case plainText
        case url
        case code
        case email
        case image
        case file
        case color
        case phoneNumber
        
        var displayName: String {
            switch self {
            case .plainText: return "Text"
            case .url: return "URL"
            case .code: return "Code"
            case .email: return "Email"
            case .image: return "Image"
            case .file: return "File"
            case .color: return "Color"
            case .phoneNumber: return "Phone"
            }
        }
        
        var icon: String {
            switch self {
            case .plainText: return "doc.text.fill"
            case .url: return "link.circle.fill"
            case .code: return "chevron.left.forwardslash.chevron.right"
            case .email: return "envelope.fill"
            case .image: return "photo.fill"
            case .file: return "doc.fill"
            case .color: return "paintpalette.fill"
            case .phoneNumber: return "phone.fill"
            }
        }
        
        var color: String {
            switch self {
            case .plainText: return "blue"
            case .url: return "green"
            case .code: return "purple"
            case .email: return "orange"
            case .image: return "pink"
            case .file: return "gray"
            case .color: return "red"
            case .phoneNumber: return "teal"
            }
        }
        
        /// Detect content type from string content
        static func detect(from content: String) -> ContentType {
            let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check for URL
            if trimmedContent.hasPrefix("http://") || trimmedContent.hasPrefix("https://") ||
               trimmedContent.hasPrefix("www.") || trimmedContent.contains("://") {
                return .url
            }
            
            // Check for email
            if trimmedContent.contains("@") && trimmedContent.contains(".") {
                let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                if trimmedContent.range(of: emailRegex, options: .regularExpression) != nil {
                    return .email
                }
            }
            
            // Check for phone number
            let phoneRegex = "^[+]?[(]?[0-9]{1,4}[)]?[-\\s\\.]?[(]?[0-9]{1,4}[)]?[-\\s\\.]?[0-9]{1,9}$"
            if trimmedContent.range(of: phoneRegex, options: .regularExpression) != nil {
                return .phoneNumber
            }
            
            // Check for code patterns
            let codePatterns = ["func ", "var ", "let ", "class ", "import ", "def ", "function ", "const ", "=>", "{", "}", "();"]
            for pattern in codePatterns {
                if trimmedContent.contains(pattern) {
                    return .code
                }
            }
            
            // Check for color hex codes
            let colorRegex = "^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$"
            if trimmedContent.range(of: colorRegex, options: .regularExpression) != nil {
                return .color
            }
            
            // Default to plain text
            return .plainText
        }
    }
}