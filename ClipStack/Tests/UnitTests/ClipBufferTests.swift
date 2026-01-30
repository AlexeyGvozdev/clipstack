//
//  ClipBufferTests.swift
//  ClipStackTests
//
//  Created by Alexey Gvozdev on 30.01.2026.
//

import XCTest
@testable import ClipStack

final class ClipBufferTests: XCTestCase {
    var buffer: ClipBuffer!
    
    override func setUp() {
        super.setUp()
        buffer = ClipBuffer(maxSize: 5)
    }
    
    override func tearDown() {
        buffer = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertEqual(buffer.maxSize, 5)
        XCTAssertEqual(buffer.count, 0)
        XCTAssertTrue(buffer.isEmpty)
        XCTAssertFalse(buffer.isFull)
        XCTAssertEqual(buffer.mode, .stack)
    }
    
    // MARK: - Push Tests
    
    func testPush() {
        let item = createTestItem("Test")
        buffer.push(item)
        
        XCTAssertEqual(buffer.count, 1)
        XCTAssertFalse(buffer.isEmpty)
        XCTAssertEqual(buffer.items.first?.content, "Test")
    }
    
    func testPushMultiple() {
        buffer.push(createTestItem("A"))
        buffer.push(createTestItem("B"))
        buffer.push(createTestItem("C"))
        
        XCTAssertEqual(buffer.count, 3)
        XCTAssertEqual(buffer.items[0].content, "A")
        XCTAssertEqual(buffer.items[1].content, "B")
        XCTAssertEqual(buffer.items[2].content, "C")
    }
    
    func testPushWhenFull() {
        // Fill buffer
        for i in 1...5 {
            buffer.push(createTestItem("Item \(i)"))
        }
        
        XCTAssertTrue(buffer.isFull)
        XCTAssertEqual(buffer.count, 5)
        
        // Push one more - should remove oldest
        buffer.push(createTestItem("Item 6"))
        
        XCTAssertEqual(buffer.count, 5)
        XCTAssertEqual(buffer.items.first?.content, "Item 2")
        XCTAssertEqual(buffer.items.last?.content, "Item 6")
    }
    
    // MARK: - Stack Mode Tests
    
    func testStackModePop() {
        buffer.mode = .stack
        buffer.push(createTestItem("A"))
        buffer.push(createTestItem("B"))
        buffer.push(createTestItem("C"))
        
        // Stack: Last In, First Out
        XCTAssertEqual(buffer.pop()?.content, "C")
        XCTAssertEqual(buffer.pop()?.content, "B")
        XCTAssertEqual(buffer.pop()?.content, "A")
        XCTAssertNil(buffer.pop())
    }
    
    func testStackModePopLast() {
        buffer.mode = .stack
        buffer.push(createTestItem("A"))
        buffer.push(createTestItem("B"))
        buffer.push(createTestItem("C"))
        
        // Stack popLast: removes from beginning
        XCTAssertEqual(buffer.popLast()?.content, "A")
        XCTAssertEqual(buffer.popLast()?.content, "B")
        XCTAssertEqual(buffer.popLast()?.content, "C")
        XCTAssertNil(buffer.popLast())
    }
    
    func testStackModePeek() {
        buffer.mode = .stack
        buffer.push(createTestItem("A"))
        buffer.push(createTestItem("B"))
        
        XCTAssertEqual(buffer.peek()?.content, "B")
        XCTAssertEqual(buffer.count, 2) // Peek doesn't remove
    }
    
    // MARK: - Queue Mode Tests
    
    func testQueueModePop() {
        buffer.mode = .queue
        buffer.push(createTestItem("A"))
        buffer.push(createTestItem("B"))
        buffer.push(createTestItem("C"))
        
        // Queue: First In, First Out
        XCTAssertEqual(buffer.pop()?.content, "A")
        XCTAssertEqual(buffer.pop()?.content, "B")
        XCTAssertEqual(buffer.pop()?.content, "C")
        XCTAssertNil(buffer.pop())
    }
    
    func testQueueModePopLast() {
        buffer.mode = .queue
        buffer.push(createTestItem("A"))
        buffer.push(createTestItem("B"))
        buffer.push(createTestItem("C"))
        
        // Queue popLast: removes from end
        XCTAssertEqual(buffer.popLast()?.content, "C")
        XCTAssertEqual(buffer.popLast()?.content, "B")
        XCTAssertEqual(buffer.popLast()?.content, "A")
        XCTAssertNil(buffer.popLast())
    }
    
    func testQueueModePeek() {
        buffer.mode = .queue
        buffer.push(createTestItem("A"))
        buffer.push(createTestItem("B"))
        
        XCTAssertEqual(buffer.peek()?.content, "A")
        XCTAssertEqual(buffer.count, 2) // Peek doesn't remove
    }
    
    // MARK: - Mode Toggle Tests
    
    func testToggleMode() {
        XCTAssertEqual(buffer.mode, .stack)
        
        buffer.toggleMode()
        XCTAssertEqual(buffer.mode, .queue)
        
        buffer.toggleMode()
        XCTAssertEqual(buffer.mode, .stack)
    }
    
    // MARK: - Clear Tests
    
    func testClear() {
        buffer.push(createTestItem("A"))
        buffer.push(createTestItem("B"))
        buffer.push(createTestItem("C"))
        
        XCTAssertEqual(buffer.count, 3)
        
        buffer.clear()
        
        XCTAssertEqual(buffer.count, 0)
        XCTAssertTrue(buffer.isEmpty)
    }
    
    // MARK: - Remove Tests
    
    func testRemoveAtIndex() {
        buffer.push(createTestItem("A"))
        buffer.push(createTestItem("B"))
        buffer.push(createTestItem("C"))
        
        buffer.remove(at: 1)
        
        XCTAssertEqual(buffer.count, 2)
        XCTAssertEqual(buffer.items[0].content, "A")
        XCTAssertEqual(buffer.items[1].content, "C")
    }
    
    func testRemoveById() {
        let item1 = createTestItem("A")
        let item2 = createTestItem("B")
        let item3 = createTestItem("C")
        
        buffer.push(item1)
        buffer.push(item2)
        buffer.push(item3)
        
        buffer.remove(id: item2.id)
        
        XCTAssertEqual(buffer.count, 2)
        XCTAssertFalse(buffer.contains(id: item2.id))
    }
    
    func testRemoveOldItems() {
        let now = Date()
        let old1 = ClipItem(content: "Old 1", timestamp: now.addingTimeInterval(-3600))
        let old2 = ClipItem(content: "Old 2", timestamp: now.addingTimeInterval(-7200))
        let recent = ClipItem(content: "Recent", timestamp: now)
        
        buffer.push(old1)
        buffer.push(old2)
        buffer.push(recent)
        
        // Remove items older than 30 minutes (1800 seconds)
        buffer.removeOldItems(olderThan: 1800)
        
        XCTAssertEqual(buffer.count, 1)
        XCTAssertEqual(buffer.items.first?.content, "Recent")
    }
    
    // MARK: - Search Tests
    
    func testSearch() {
        buffer.push(createTestItem("Hello World"))
        buffer.push(createTestItem("Swift Programming"))
        buffer.push(createTestItem("Hello Swift"))
        
        let results = buffer.search(query: "Hello")
        
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.contains { $0.content == "Hello World" })
        XCTAssertTrue(results.contains { $0.content == "Hello Swift" })
    }
    
    func testSearchCaseInsensitive() {
        buffer.push(createTestItem("UPPERCASE"))
        buffer.push(createTestItem("lowercase"))
        buffer.push(createTestItem("MixedCase"))
        
        let results = buffer.search(query: "case")
        
        XCTAssertEqual(results.count, 2)
    }
    
    // MARK: - Helper Methods
    
    private func createTestItem(_ content: String) -> ClipItem {
        ClipItem(content: content)
    }
}