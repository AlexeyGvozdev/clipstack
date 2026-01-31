//
//  BlacklistManagerTests.swift
//  ClipStackTests
//
//  Created by ClipStack on 2026-01-31.
//

import XCTest
@testable import ClipStack

final class BlacklistManagerTests: XCTestCase {
    var manager: BlacklistManager!
    var mockStorage: MockBlacklistStorage!
    
    override func setUp() {
        super.setUp()
        mockStorage = MockBlacklistStorage()
        manager = BlacklistManager(storage: mockStorage)
    }
    
    override func tearDown() {
        manager = nil
        mockStorage = nil
        super.tearDown()
    }
    
    // MARK: - Basic Functionality Tests
    
    func testAddRule() {
        let rule = BlacklistRule(pattern: "localhost")
        manager.addRule(rule)
        
        XCTAssertEqual(manager.rules.count, 1)
        XCTAssertEqual(manager.rules.first?.pattern, "localhost")
        XCTAssertTrue(mockStorage.saveCalled)
    }
    
    func testRemoveRule() {
        let rule = BlacklistRule(pattern: "localhost")
        manager.addRule(rule)
        
        manager.removeRule(id: rule.id)
        
        XCTAssertEqual(manager.rules.count, 0)
        XCTAssertTrue(mockStorage.saveCalled)
    }
    
    func testUpdateRule() {
        var rule = BlacklistRule(pattern: "localhost")
        manager.addRule(rule)
        
        rule.pattern = "127.0.0.1"
        manager.updateRule(rule)
        
        XCTAssertEqual(manager.rules.first?.pattern, "127.0.0.1")
        XCTAssertTrue(mockStorage.saveCalled)
    }
    
    func testToggleRule() {
        let rule = BlacklistRule(pattern: "localhost", isEnabled: true)
        manager.addRule(rule)
        
        manager.toggleRule(id: rule.id)
        
        XCTAssertFalse(manager.rules.first?.isEnabled ?? true)
        
        manager.toggleRule(id: rule.id)
        
        XCTAssertTrue(manager.rules.first?.isEnabled ?? false)
    }
    
    // MARK: - Blacklist Check Tests
    
    func testSimpleBlacklist() {
        let rule = BlacklistRule(pattern: "localhost")
        manager.addRule(rule)
        
        let result = manager.isBlacklisted("http://localhost:3000")
        
        XCTAssertTrue(result.blocked)
        XCTAssertEqual(result.matchedRule?.pattern, "localhost")
    }
    
    func testCaseInsensitiveBlacklist() {
        let rule = BlacklistRule(pattern: "localhost", isCaseSensitive: false)
        manager.addRule(rule)
        
        XCTAssertTrue(manager.isBlacklisted("http://LOCALHOST:3000").blocked)
        XCTAssertTrue(manager.isBlacklisted("http://LocalHost:3000").blocked)
        XCTAssertTrue(manager.isBlacklisted("http://localhost:3000").blocked)
    }
    
    func testCaseSensitiveBlacklist() {
        let rule = BlacklistRule(pattern: "SECRET", isCaseSensitive: true)
        manager.addRule(rule)
        
        XCTAssertTrue(manager.isBlacklisted("SECRET document").blocked)
        XCTAssertFalse(manager.isBlacklisted("secret document").blocked)
        XCTAssertFalse(manager.isBlacklisted("Secret document").blocked)
    }
    
    func testDisabledRule() {
        var rule = BlacklistRule(pattern: "test")
        rule.isEnabled = false
        manager.addRule(rule)
        
        let result = manager.isBlacklisted("test content")
        
        XCTAssertFalse(result.blocked)
        XCTAssertNil(result.matchedRule)
    }
    
    func testMultipleRules() {
        manager.addRule(BlacklistRule(pattern: "localhost"))
        manager.addRule(BlacklistRule(pattern: "tmp"))
        manager.addRule(BlacklistRule(pattern: "test"))
        
        XCTAssertTrue(manager.isBlacklisted("http://localhost:3000").blocked)
        XCTAssertTrue(manager.isBlacklisted("tmp_file.txt").blocked)
        XCTAssertTrue(manager.isBlacklisted("test_data.json").blocked)
        XCTAssertFalse(manager.isBlacklisted("production.com").blocked)
    }
    
    func testNoMatch() {
        manager.addRule(BlacklistRule(pattern: "localhost"))
        
        let result = manager.isBlacklisted("https://example.com")
        
        XCTAssertFalse(result.blocked)
        XCTAssertNil(result.matchedRule)
    }
    
    func testPartialMatch() {
        manager.addRule(BlacklistRule(pattern: "tmp"))
        
        XCTAssertTrue(manager.isBlacklisted("tmp_file.txt").blocked)
        XCTAssertTrue(manager.isBlacklisted("file_tmp.txt").blocked)
        XCTAssertTrue(manager.isBlacklisted("temporary").blocked)
    }
    
    // MARK: - Preset Tests
    
    func testLoadDefaultRules() {
        manager.loadDefaultRules()
        
        XCTAssertGreaterThan(manager.rules.count, 0)
        XCTAssertTrue(manager.rules.contains { $0.pattern == "localhost" })
        XCTAssertTrue(manager.rules.contains { $0.pattern == "127.0.0.1" })
        XCTAssertTrue(manager.rules.contains { $0.pattern == "tmp" })
        XCTAssertTrue(manager.rules.contains { $0.pattern == "CONFIDENTIAL" })
    }
    
    func testLoadDevelopmentPreset() {
        manager.loadDevelopmentPreset()
        
        XCTAssertGreaterThan(manager.rules.count, 0)
        XCTAssertTrue(manager.rules.contains { $0.pattern == "localhost" })
        XCTAssertTrue(manager.rules.contains { $0.pattern == "debug" })
    }
    
    func testLoadPrivacyPreset() {
        manager.loadPrivacyPreset()
        
        XCTAssertGreaterThan(manager.rules.count, 0)
        XCTAssertTrue(manager.rules.contains { $0.pattern == "CONFIDENTIAL" })
        XCTAssertTrue(manager.rules.contains { $0.pattern == "SECRET" })
    }
    
    func testLoadTemporaryFilesPreset() {
        manager.loadTemporaryFilesPreset()
        
        XCTAssertGreaterThan(manager.rules.count, 0)
        XCTAssertTrue(manager.rules.contains { $0.pattern == "tmp" })
        XCTAssertTrue(manager.rules.contains { $0.pattern == ".bak" })
    }
    
    // MARK: - Statistics Tests
    
    func testActiveRulesCount() {
        manager.addRule(BlacklistRule(pattern: "test1", isEnabled: true))
        manager.addRule(BlacklistRule(pattern: "test2", isEnabled: true))
        manager.addRule(BlacklistRule(pattern: "test3", isEnabled: false))
        
        XCTAssertEqual(manager.activeRulesCount, 2)
        XCTAssertEqual(manager.totalRulesCount, 3)
    }
    
    func testClearAll() {
        manager.addRule(BlacklistRule(pattern: "test1"))
        manager.addRule(BlacklistRule(pattern: "test2"))
        
        manager.clearAll()
        
        XCTAssertEqual(manager.rules.count, 0)
        XCTAssertTrue(mockStorage.saveCalled)
    }
    
    // MARK: - Import/Export Tests
    
    func testExportToFile() throws {
        manager.addRule(BlacklistRule(pattern: "localhost", description: "Local server"))
        manager.addRule(BlacklistRule(pattern: "tmp", description: "Temp files"))
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_export.json")
        
        try manager.exportToFile(url: tempURL)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempURL.path))
        
        let data = try Data(contentsOf: tempURL)
        let export = try JSONDecoder().decode(BlacklistExport.self, from: data)
        
        XCTAssertEqual(export.version, "1.0")
        XCTAssertEqual(export.rules.count, 2)
        
        try? FileManager.default.removeItem(at: tempURL)
    }
    
    func testImportFromFile() throws {
        let rules = [
            BlacklistRule(pattern: "localhost", description: "Local server"),
            BlacklistRule(pattern: "tmp", description: "Temp files")
        ]
        
        let export = BlacklistExport(version: "1.0", rules: rules)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(export)
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_import.json")
        try data.write(to: tempURL)
        
        try manager.importFromFile(url: tempURL, merge: false)
        
        XCTAssertEqual(manager.rules.count, 2)
        XCTAssertTrue(manager.rules.contains { $0.pattern == "localhost" })
        XCTAssertTrue(manager.rules.contains { $0.pattern == "tmp" })
        
        try? FileManager.default.removeItem(at: tempURL)
    }
    
    func testImportWithMerge() throws {
        manager.addRule(BlacklistRule(pattern: "existing"))
        
        let rules = [
            BlacklistRule(pattern: "localhost"),
            BlacklistRule(pattern: "existing") // Duplicate
        ]
        
        let export = BlacklistExport(version: "1.0", rules: rules)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(export)
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_merge.json")
        try data.write(to: tempURL)
        
        try manager.importFromFile(url: tempURL, merge: true)
        
        XCTAssertEqual(manager.rules.count, 2) // Should not duplicate "existing"
        
        try? FileManager.default.removeItem(at: tempURL)
    }
    
    // MARK: - Real-world Scenarios
    
    func testDevelopmentWorkflow() {
        manager.loadDevelopmentPreset()
        
        // Test blocking localhost URLs
        XCTAssertTrue(manager.isBlacklisted("http://localhost:3000/api").blocked)
        XCTAssertTrue(manager.isBlacklisted("http://127.0.0.1:8080").blocked)
        
        // Test blocking temp files
        XCTAssertTrue(manager.isBlacklisted("tmp_backup.sql").blocked)
        XCTAssertTrue(manager.isBlacklisted("test_data.json").blocked)
        
        // Test allowing production URLs
        XCTAssertFalse(manager.isBlacklisted("https://api.production.com").blocked)
    }
    
    func testPrivacyWorkflow() {
        manager.loadPrivacyPreset()
        
        // Test blocking confidential content
        XCTAssertTrue(manager.isBlacklisted("CONFIDENTIAL: Project Alpha").blocked)
        XCTAssertTrue(manager.isBlacklisted("SECRET document").blocked)
        
        // Test case sensitivity
        XCTAssertFalse(manager.isBlacklisted("confidential information").blocked)
        
        // Test allowing normal content
        XCTAssertFalse(manager.isBlacklisted("Public announcement").blocked)
    }
}

// MARK: - Mock Storage

class MockBlacklistStorage: BlacklistStorage {
    var rules: [BlacklistRule] = []
    var saveCalled = false
    var loadCalled = false
    
    func save(_ rules: [BlacklistRule]) {
        self.rules = rules
        saveCalled = true
    }
    
    func load() -> [BlacklistRule] {
        loadCalled = true
        return rules
    }
}