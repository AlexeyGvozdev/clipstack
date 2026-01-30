//
//  ClipBufferProtocol.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 30.01.2026.
//

import Foundation

/// Protocol defining clipboard buffer operations
protocol ClipBufferProtocol: AnyObject {
    /// Current buffer mode (Stack or Queue)
    var mode: BufferMode { get set }
    
    /// All items in the buffer
    var items: [ClipItem] { get }
    
    /// Maximum number of items the buffer can hold
    var maxSize: Int { get }
    
    /// Current number of items in the buffer
    var count: Int { get }
    
    /// Whether the buffer is empty
    var isEmpty: Bool { get }
    
    /// Whether the buffer is full
    var isFull: Bool { get }
    
    /// Add an item to the buffer
    /// - Parameter item: The item to add
    func push(_ item: ClipItem)
    
    /// Remove and return the first item according to the current mode
    /// - Returns: The first item, or nil if buffer is empty
    func pop() -> ClipItem?
    
    /// Remove and return the last item according to the current mode
    /// - Returns: The last item, or nil if buffer is empty
    func popLast() -> ClipItem?
    
    /// View the first item without removing it
    /// - Returns: The first item, or nil if buffer is empty
    func peek() -> ClipItem?
    
    /// View the last item without removing it
    /// - Returns: The last item, or nil if buffer is empty
    func peekLast() -> ClipItem?
    
    /// Remove all items from the buffer
    func clear()
    
    /// Remove item at specific index
    /// - Parameter index: The index of the item to remove
    func remove(at index: Int)
    
    /// Remove item by ID
    /// - Parameter id: The ID of the item to remove
    func remove(id: UUID)
    
    /// Toggle between Stack and Queue modes
    func toggleMode()
    
    /// Remove items older than specified age
    /// - Parameter age: Maximum age in seconds
    func removeOldItems(olderThan age: TimeInterval)
}