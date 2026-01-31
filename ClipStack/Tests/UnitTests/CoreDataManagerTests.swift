//
//  CoreDataManagerTests.swift
//  ClipStackTests
//
//  Created by Alexey Gvozdev on 31.01.2026.
//

import XCTest
import CoreData
@testable import ClipStack

final class CoreDataManagerTests: XCTestCase {
    var manager: CoreDataManager!
    
    override func setUp() {
        super.setUp()
        manager = CoreDataManager.shared
        
        // Clean up before each test
        try? manager.deleteAllItems()
    }
    
    override func tearDown() {
        // Clean up after each test
        try? manager.deleteAllItems()
        manager = nil
        super.tearDown()
    }
    
    // MARK: - Save Tests
    
    func testSaveSingleItem() throws {
        // Given
        let item = ClipItem(content: "Test content", contentType: .plainText)
        
        // When
        try manager.saveItem(item)
        
        // Then
        let loadedItems = try manager.loadItems()
        XCTAssertEqual(loadedItems.count, 1)
        XCTAssertEqual(loadedItems.first?.content, "Test content")
        XCTAssertEqual(loadedItems.first?.contentType, .plainText)
    }
    
    func testSaveMultipleItems() throws {
        // Given
        let items = [
            ClipItem(content: "Item 1", contentType: .plainText),
            ClipItem(content: "Item 2", contentType: .url),
            ClipItem(content: "Item 3", contentType: .code)
        ]
        
        // When
        try manager.saveItems(items)
        
        // Then
        let loadedItems = try manager.loadItems()
        XCTAssertEqual(loadedItems.count, 3)
    }
    
    func testSaveItemWithSourceApp() throws {
        // Given
        let item = ClipItem(
            content: "Test",
            sourceApp: "Safari",
            contentType: .url
        )
        
        // When
        try manager.saveItem(item)
        
        // Then
        let loadedItems = try manager.loadItems()
        XCTAssertEqual(loadedItems.first?.sourceApp, "Safari")
    }
    
    // MARK: - Load Tests
    
    func testLoadItemsWithLimit() throws {
        // Given
        let items = (1...10).map { ClipItem(content: "Item \($0)") }
        try manager.saveItems(items)
        
        // When
        let loadedItems = try manager.loadItems(limit: 5)
        
        // Then
        XCTAssertEqual(loadedItems.count, 5)
    }
    
    func testLoadItemsByContentType() throws {
        // Given
        let items = [
            ClipItem(content: "Text 1", contentType: .plainText),
            ClipItem(content: "https://example.com", contentType: .url),
            ClipItem(content: "Text 2", contentType: .plainText),
            ClipItem(content: "code", contentType: .code)
        ]
        try manager.saveItems(items)
        
        // When
        let textItems = try manager.loadItems(ofType: .plainText)
        
        // Then
        XCTAssertEqual(textItems.count, 2)
        XCTAssertTrue(textItems.allSatisfy { $0.contentType == .plainText })
    }
    
    func testLoadItemsBySourceApp() throws {
        // Given
        let items = [
            ClipItem(content: "Item 1", sourceApp: "Safari"),
            ClipItem(content: "Item 2", sourceApp: "Chrome"),
            ClipItem(content: "Item 3", sourceApp: "Safari")
        ]
        try manager.saveItems(items)
        
        // When
        let safariItems = try manager.loadItems(fromApp: "Safari")
        
        // Then
        XCTAssertEqual(safariItems.count, 2)
        XCTAssertTrue(safariItems.allSatisfy { $0.sourceApp == "Safari" })
    }
    
    func testLoadItemsSortedByTimestamp() throws {
        // Given
        let now = Date()
        let items = [
            ClipItem(content: "Old", timestamp: now.addingTimeInterval(-100)),
            ClipItem(content: "New", timestamp: now),
            ClipItem(content: "Middle", timestamp: now.addingTimeInterval(-50))
        ]
        try manager.saveItems(items)
        
        // When
        let loadedItems = try manager.loadItems()
        
        // Then
        XCTAssertEqual(loadedItems.count, 3)
        XCTAssertEqual(loadedItems[0].content, "New") // Newest first
        XCTAssertEqual(loadedItems[1].content, "Middle")
        XCTAssertEqual(loadedItems[2].content, "Old")
    }
    
    // MARK: - Delete Tests
    
    func testDeleteSingleItem() throws {
        // Given
        let item = ClipItem(content: "Test")
        try manager.saveItem(item)
        
        // When
        try manager.deleteItem(withId: item.id)
        
        // Then
        let loadedItems = try manager.loadItems()
        XCTAssertEqual(loadedItems.count, 0)
    }
    
    func testDeleteMultipleItems() throws {
        // Given
        let items = [
            ClipItem(content: "Item 1"),
            ClipItem(content: "Item 2"),
            ClipItem(content: "Item 3")
        ]
        try manager.saveItems(items)
        
        let idsToDelete = [items[0].id, items[2].id]
        
        // When
        try manager.deleteItems(withIds: idsToDelete)
        
        // Then
        let loadedItems = try manager.loadItems()
        XCTAssertEqual(loadedItems.count, 1)
        XCTAssertEqual(loadedItems.first?.content, "Item 2")
    }
    
    func testDeleteAllItems() throws {
        // Given
        let items = (1...5).map { ClipItem(content: "Item \($0)") }
        try manager.saveItems(items)
        
        // When
        try manager.deleteAllItems()
        
        // Then
        let loadedItems = try manager.loadItems()
        XCTAssertEqual(loadedItems.count, 0)
    }
    
    func testDeleteOldItems() throws {
        // Given
        let now = Date()
        let items = [
            ClipItem(content: "Old 1", timestamp: now.addingTimeInterval(-200)),
            ClipItem(content: "Recent", timestamp: now.addingTimeInterval(-50)),
            ClipItem(content: "Old 2", timestamp: now.addingTimeInterval(-150))
        ]
        try manager.saveItems(items)
        
        // When
        let cutoffDate = now.addingTimeInterval(-100)
        let deletedCount = try manager.deleteItems(olderThan: cutoffDate)
        
        // Then
        XCTAssertEqual(deletedCount, 2)
        let remainingItems = try manager.loadItems()
        XCTAssertEqual(remainingItems.count, 1)
        XCTAssertEqual(remainingItems.first?.content, "Recent")
    }
    
    // MARK: - Statistics Tests
    
    func testGetItemCount() throws {
        // Given
        let items = (1...7).map { ClipItem(content: "Item \($0)") }
        try manager.saveItems(items)
        
        // When
        let count = try manager.getItemCount()
        
        // Then
        XCTAssertEqual(count, 7)
    }
    
    func testGetItemCountByType() throws {
        // Given
        let items = [
            ClipItem(content: "Text 1", contentType: .plainText),
            ClipItem(content: "URL", contentType: .url),
            ClipItem(content: "Text 2", contentType: .plainText),
            ClipItem(content: "Code", contentType: .code),
            ClipItem(content: "Text 3", contentType: .plainText)
        ]
        try manager.saveItems(items)
        
        // When
        let textCount = try manager.getItemCount(ofType: .plainText)
        let urlCount = try manager.getItemCount(ofType: .url)
        
        // Then
        XCTAssertEqual(textCount, 3)
        XCTAssertEqual(urlCount, 1)
    }
    
    func testGetStorageSizeEstimate() throws {
        // Given
        let items = [
            ClipItem(content: "Short", sourceApp: "App1"),
            ClipItem(content: "A longer piece of content", sourceApp: "App2")
        ]
        try manager.saveItems(items)
        
        // When
        let size = try manager.getStorageSizeEstimate()
        
        // Then
        XCTAssertGreaterThan(size, 0)
    }
    
    // MARK: - Maintenance Tests
    
    func testCleanupOldItems() throws {
        // Given
        let now = Date()
        let items = [
            ClipItem(content: "Very old", timestamp: now.addingTimeInterval(-10 * 24 * 3600)),
            ClipItem(content: "Recent", timestamp: now.addingTimeInterval(-1 * 24 * 3600)),
            ClipItem(content: "Old", timestamp: now.addingTimeInterval(-8 * 24 * 3600))
        ]
        try manager.saveItems(items)
        
        // When
        let deletedCount = try manager.cleanupOldItems(olderThanDays: 7)
        
        // Then
        XCTAssertEqual(deletedCount, 2)
        let remainingItems = try manager.loadItems()
        XCTAssertEqual(remainingItems.count, 1)
        XCTAssertEqual(remainingItems.first?.content, "Recent")
    }
    
    func testResetDatabase() throws {
        // Given
        let items = (1...5).map { ClipItem(content: "Item \($0)") }
        try manager.saveItems(items)
        
        // When
        try manager.resetDatabase()
        
        // Then
        let loadedItems = try manager.loadItems()
        XCTAssertEqual(loadedItems.count, 0)
    }
}