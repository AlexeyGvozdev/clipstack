//
//  ClipBuffer.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 30.01.2026.
//

import Foundation
import Combine

/// Main clipboard buffer implementation
final class ClipBuffer: ClipBufferProtocol, ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var items: [ClipItem] = []
    @Published var mode: BufferMode = .stack
    
    // MARK: - Properties
    
    let maxSize: Int
    private let autoClearManager: AutoClearManager?
    
    var count: Int {
        items.count
    }
    
    var isEmpty: Bool {
        items.isEmpty
    }
    
    var isFull: Bool {
        items.count >= maxSize
    }
    
    // MARK: - Initialization
    
    init(maxSize: Int = 100, autoClearManager: AutoClearManager? = nil) {
        self.maxSize = maxSize
        self.autoClearManager = autoClearManager
        self.autoClearManager?.delegate = self
    }
    
    // MARK: - Public Methods
    
    func push(_ item: ClipItem) {
        // Remove oldest item if buffer is full
        if isFull {
            items.removeFirst()
        }
        
        items.append(item)
        
        // Notify auto-clear manager about activity
        autoClearManager?.handleActivity()
    }
    
    func pop() -> ClipItem? {
        guard !isEmpty else { return nil }
        
        // Stack (LIFO): remove from end
        // Queue (FIFO): remove from beginning
        return mode == .stack ? items.removeLast() : items.removeFirst()
    }
    
    func popLast() -> ClipItem? {
        guard !isEmpty else { return nil }
        
        // Stack (LIFO): remove from beginning (opposite end)
        // Queue (FIFO): remove from end (opposite end)
        return mode == .stack ? items.removeFirst() : items.removeLast()
    }
    
    func peek() -> ClipItem? {
        guard !isEmpty else { return nil }
        
        // Stack (LIFO): view last item
        // Queue (FIFO): view first item
        return mode == .stack ? items.last : items.first
    }
    
    func peekLast() -> ClipItem? {
        guard !isEmpty else { return nil }
        
        // Stack (LIFO): view first item (opposite end)
        // Queue (FIFO): view last item (opposite end)
        return mode == .stack ? items.first : items.last
    }
    
    func clear() {
        items.removeAll()
    }
    
    /// Clear buffer and return count of removed items
    /// - Returns: Number of items removed
    @discardableResult
    func clearAndCount() -> Int {
        let count = items.count
        items.removeAll()
        return count
    }
    
    /// Remove old items and return count of removed items
    /// - Parameter age: Maximum age in seconds
    /// - Returns: Number of items removed
    @discardableResult
    func removeOldItemsAndCount(olderThan age: TimeInterval) -> Int {
        let beforeCount = items.count
        removeOldItems(olderThan: age)
        return beforeCount - items.count
    }
    
    func remove(at index: Int) {
        guard index >= 0 && index < items.count else { return }
        items.remove(at: index)
    }
    
    func remove(id: UUID) {
        items.removeAll { $0.id == id }
    }
    
    func toggleMode() {
        mode.toggle()
    }
    
    func removeOldItems(olderThan age: TimeInterval) {
        let cutoffDate = Date().addingTimeInterval(-age)
        items.removeAll { $0.timestamp < cutoffDate }
    }
}

// MARK: - Convenience Methods

extension ClipBuffer {
    /// Get item at specific index
    func item(at index: Int) -> ClipItem? {
        guard index >= 0 && index < items.count else { return nil }
        return items[index]
    }
    
    /// Check if buffer contains item with specific ID
    func contains(id: UUID) -> Bool {
        items.contains { $0.id == id }
    }
    
    /// Get index of item with specific ID
    func index(of id: UUID) -> Int? {
        items.firstIndex { $0.id == id }
    }
    
    /// Get all items of specific content type
    func items(ofType type: ClipItem.ContentType) -> [ClipItem] {
        items.filter { $0.contentType == type }
    }
    
    /// Search items by content
    func search(query: String) -> [ClipItem] {
        guard !query.isEmpty else { return items }
        return items.filter { $0.content.localizedCaseInsensitiveContains(query) }
    }
}

// MARK: - AutoClearManagerDelegate

extension ClipBuffer: AutoClearManagerDelegate {
    func autoClearShouldClearBuffer() -> Int {
        return clearAndCount()
    }
    
    func autoClearShouldClearOldItems(olderThan age: TimeInterval) -> Int {
        return removeOldItemsAndCount(olderThan: age)
    }
}