//
//  BufferMode.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 30.01.2026.
//

import Foundation

/// Buffer operation mode
enum BufferMode: String, Codable, CaseIterable {
    /// Stack mode - Last In, First Out (LIFO)
    case stack
    
    /// Queue mode - First In, First Out (FIFO)
    case queue
    
    /// Human-readable display name
    var displayName: String {
        switch self {
        case .stack:
            return "Stack (LIFO)"
        case .queue:
            return "Queue (FIFO)"
        }
    }
    
    /// Short description of the mode
    var description: String {
        switch self {
        case .stack:
            return "Last copied item is pasted first"
        case .queue:
            return "First copied item is pasted first"
        }
    }
    
    /// SF Symbol icon name
    var icon: String {
        switch self {
        case .stack:
            return "arrow.up.arrow.down"
        case .queue:
            return "arrow.right.arrow.left"
        }
    }
    
    /// Toggle to the other mode
    mutating func toggle() {
        self = self == .stack ? .queue : .stack
    }
    
    /// Get the opposite mode
    var toggled: BufferMode {
        self == .stack ? .queue : .stack
    }
}