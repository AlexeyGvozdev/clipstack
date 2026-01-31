//
//  ClipBuffer.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 30.01.2026.
//

import Foundation
import Combine
import CoreData

/// Main clipboard buffer implementation
final class ClipBuffer: ClipBufferProtocol, ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var items: [ClipItem] = []
    @Published var mode: BufferMode = .stack
    
    // MARK: - Properties
    
    let maxSize: Int
    private let autoClearManager: AutoClearManager?
    private let coreDataManager: CoreDataManager
    private let settingsManager: SettingsManager
    
    // Auto-save timer
    private var autoSaveTimer: Timer?
    
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
    
    init(maxSize: Int = 100, autoClearManager: AutoClearManager? = nil,
         coreDataManager: CoreDataManager = .shared,
         settingsManager: SettingsManager = .shared) {
        self.maxSize = maxSize
        self.autoClearManager = autoClearManager
        self.coreDataManager = coreDataManager
        self.settingsManager = settingsManager
        
        // Set delegates
        self.autoClearManager?.delegate = self
        
        // Load items from Core Data if auto-save is enabled
        if settingsManager.enableAutoSave {
            loadItemsFromStorage()
        }
        
        // Setup auto-save timer
        setupAutoSave()
    }
    
    deinit {
        autoSaveTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    func push(_ item: ClipItem) {
        // Remove oldest item if buffer is full
        if isFull {
            items.removeFirst()
        }
        
        items.append(item)
        
        // Save to Core Data if auto-save is enabled
        if settingsManager.enableAutoSave {
            saveItemToStorage(item)
        }
        
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
        
        // Clear from Core Data if auto-save is enabled
        if settingsManager.enableAutoSave {
            clearStorage()
        }
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
        let item = items[index]
        items.remove(at: index)
        
        // Remove from Core Data if auto-save is enabled
        if settingsManager.enableAutoSave {
            removeItemFromStorage(item)
        }
    }
    
    func remove(id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            remove(at: index)
        }
    }
    
    func toggleMode() {
        mode.toggle()
        
        // Save mode to settings
        settingsManager.bufferMode = mode
    }
    
    func removeOldItems(olderThan age: TimeInterval) {
        let cutoffDate = Date().addingTimeInterval(-age)
        items.removeAll { $0.timestamp < cutoffDate }
    }
}

// MARK: - Core Data Integration

private extension ClipBuffer {
    /// Setup auto-save timer
    func setupAutoSave() {
        guard settingsManager.enableAutoSave else { return }
        
        autoSaveTimer = Timer.scheduledTimer(
            withTimeInterval: settingsManager.autoSaveInterval,
            repeats: true
        ) { [weak self] _ in
            self?.saveAllItemsToStorage()
        }
    }
    
    /// Load items from Core Data storage
    func loadItemsFromStorage() {
        do {
            let loadedItems = try coreDataManager.loadItems(limit: maxSize)
            items = loadedItems
            
            // Load mode from settings
            mode = settingsManager.bufferMode
        } catch {
            print("Failed to load items from storage: \(error)")
        }
    }
    
    /// Save single item to Core Data
    func saveItemToStorage(_ item: ClipItem) {
        do {
            try coreDataManager.saveItem(item)
        } catch {
            print("Failed to save item to storage: \(error)")
        }
    }
    
    /// Save all items to Core Data
    func saveAllItemsToStorage() {
        do {
            try coreDataManager.deleteAllItems()
            try coreDataManager.saveItems(items)
        } catch {
            print("Failed to save all items to storage: \(error)")
        }
    }
    
    /// Remove item from Core Data
    func removeItemFromStorage(_ item: ClipItem) {
        do {
            try coreDataManager.deleteItem(withId: item.id)
        } catch {
            print("Failed to remove item from storage: \(error)")
        }
    }
    
    /// Clear all items from Core Data
    func clearStorage() {
        do {
            try coreDataManager.deleteAllItems()
        } catch {
            print("Failed to clear storage: \(error)")
        }
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