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
        
        var displayName: String {
            switch self {
            case .plainText: return "Text"
            case .url: return "URL"
            case .code: return "Code"
            case .email: return "Email"
            }
        }
        
        var icon: String {
            switch self {
            case .plainText: return "doc.text"
            case .url: return "link"
            case .code: return "chevron.left.forwardslash.chevron.right"
            case .email: return "envelope"
            }
        }
    }
}