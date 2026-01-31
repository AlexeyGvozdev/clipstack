//
//  SettingsManagerTests.swift
//  ClipStackTests
//
//  Created by Alexey Gvozdev on 31.01.2026.
//

import XCTest
@testable import ClipStack

final class SettingsManagerTests: XCTestCase {
    var manager: SettingsManager!
    
    override func setUp() {
        super.setUp()
        manager = SettingsManager.shared
        
        // Reset to defaults before each test
        manager.resetToDefaults()
    }
    
    override func tearDown() {
        // Clean up after each test
        manager.resetToDefaults()
        manager = nil
        super.tearDown()
    }
    
    // MARK: - Buffer Settings Tests
    
    func testDefaultBufferMode() {
        // Then
        XCTAssertEqual(manager.bufferMode, .stack)
    }
    
    func testSetBufferMode() {
        // When
        manager.bufferMode = .queue
        
        // Then
        XCTAssertEqual(manager.bufferMode, .queue)
    }
    
    func testDefaultMaxBufferSize() {
        // Then
        XCTAssertEqual(manager.maxBufferSize, 100)
    }
    
    func testSetMaxBufferSize() {
        // When
        manager.maxBufferSize = 200
        
        // Then
        XCTAssertEqual(manager.maxBufferSize, 200)
    }
    
    // MARK: - Notification Settings Tests
    
    func testDefaultEnableNotifications() {
        // Then
        XCTAssertFalse(manager.enableNotifications)
    }
    
    func testSetEnableNotifications() {
        // When
        manager.enableNotifications = true
        
        // Then
        XCTAssertTrue(manager.enableNotifications)
    }
    
    // MARK: - Auto-Save Settings Tests
    
    func testDefaultEnableAutoSave() {
        // Then
        XCTAssertTrue(manager.enableAutoSave)
    }
    
    func testSetEnableAutoSave() {
        // When
        manager.enableAutoSave = false
        
        // Then
        XCTAssertFalse(manager.enableAutoSave)
    }
    
    func testDefaultAutoSaveInterval() {
        // Then
        XCTAssertEqual(manager.autoSaveInterval, 30.0)
    }
    
    func testSetAutoSaveInterval() {
        // When
        manager.autoSaveInterval = 60.0
        
        // Then
        XCTAssertEqual(manager.autoSaveInterval, 60.0)
    }
    
    // MARK: - Security Settings Tests
    
    func testDefaultEnableSecurityFilter() {
        // Then
        XCTAssertTrue(manager.enableSecurityFilter)
    }
    
    func testSetEnableSecurityFilter() {
        // When
        manager.enableSecurityFilter = false
        
        // Then
        XCTAssertFalse(manager.enableSecurityFilter)
    }
    
    func testDefaultEnableBlacklist() {
        // Then
        XCTAssertTrue(manager.enableBlacklist)
    }
    
    func testSetEnableBlacklist() {
        // When
        manager.enableBlacklist = false
        
        // Then
        XCTAssertFalse(manager.enableBlacklist)
    }
    
    func testDefaultEnableAutoClear() {
        // Then
        XCTAssertFalse(manager.enableAutoClear)
    }
    
    func testSetEnableAutoClear() {
        // When
        manager.enableAutoClear = true
        
        // Then
        XCTAssertTrue(manager.enableAutoClear)
    }
    
    // MARK: - App Settings Tests
    
    func testDefaultLaunchAtLogin() {
        // Then
        XCTAssertFalse(manager.launchAtLogin)
    }
    
    func testSetLaunchAtLogin() {
        // When
        manager.launchAtLogin = true
        
        // Then
        XCTAssertTrue(manager.launchAtLogin)
    }
    
    func testDefaultShowInDock() {
        // Then
        XCTAssertFalse(manager.showInDock)
    }
    
    func testSetShowInDock() {
        // When
        manager.showInDock = true
        
        // Then
        XCTAssertTrue(manager.showInDock)
    }
    
    func testDefaultTheme() {
        // Then
        XCTAssertEqual(manager.theme, .system)
    }
    
    func testSetTheme() {
        // When
        manager.theme = .dark
        
        // Then
        XCTAssertEqual(manager.theme, .dark)
    }
    
    // MARK: - Reset Tests
    
    func testResetToDefaults() {
        // Given
        manager.bufferMode = .queue
        manager.maxBufferSize = 200
        manager.enableNotifications = true
        manager.enableAutoSave = false
        manager.theme = .dark
        
        // When
        manager.resetToDefaults()
        
        // Then
        XCTAssertEqual(manager.bufferMode, .stack)
        XCTAssertEqual(manager.maxBufferSize, 100)
        XCTAssertFalse(manager.enableNotifications)
        XCTAssertTrue(manager.enableAutoSave)
        XCTAssertEqual(manager.theme, .system)
    }
    
    // MARK: - Export/Import Tests
    
    func testExportSettings() {
        // Given
        manager.bufferMode = .queue
        manager.maxBufferSize = 150
        manager.enableNotifications = true
        manager.theme = .dark
        
        // When
        let exported = manager.exportSettings()
        
        // Then
        XCTAssertEqual(exported["bufferMode"] as? String, "queue")
        XCTAssertEqual(exported["maxBufferSize"] as? Int, 150)
        XCTAssertEqual(exported["enableNotifications"] as? Bool, true)
        XCTAssertEqual(exported["theme"] as? String, "dark")
    }
    
    func testImportSettings() {
        // Given
        let settings: [String: Any] = [
            "bufferMode": "queue",
            "maxBufferSize": 250,
            "enableNotifications": true,
            "enableAutoSave": false,
            "autoSaveInterval": 45.0,
            "enableSecurityFilter": false,
            "enableBlacklist": false,
            "enableAutoClear": true,
            "launchAtLogin": true,
            "showInDock": true,
            "theme": "light"
        ]
        
        // When
        manager.importSettings(settings)
        
        // Then
        XCTAssertEqual(manager.bufferMode, .queue)
        XCTAssertEqual(manager.maxBufferSize, 250)
        XCTAssertTrue(manager.enableNotifications)
        XCTAssertFalse(manager.enableAutoSave)
        XCTAssertEqual(manager.autoSaveInterval, 45.0)
        XCTAssertFalse(manager.enableSecurityFilter)
        XCTAssertFalse(manager.enableBlacklist)
        XCTAssertTrue(manager.enableAutoClear)
        XCTAssertTrue(manager.launchAtLogin)
        XCTAssertTrue(manager.showInDock)
        XCTAssertEqual(manager.theme, .light)
    }
    
    func testImportPartialSettings() {
        // Given
        manager.bufferMode = .stack
        manager.maxBufferSize = 100
        
        let partialSettings: [String: Any] = [
            "bufferMode": "queue"
            // Other settings not included
        ]
        
        // When
        manager.importSettings(partialSettings)
        
        // Then
        XCTAssertEqual(manager.bufferMode, .queue)
        XCTAssertEqual(manager.maxBufferSize, 100) // Should remain unchanged
    }
    
    func testImportInvalidSettings() {
        // Given
        manager.bufferMode = .stack
        
        let invalidSettings: [String: Any] = [
            "bufferMode": "invalid_mode"
        ]
        
        // When
        manager.importSettings(invalidSettings)
        
        // Then
        XCTAssertEqual(manager.bufferMode, .stack) // Should remain unchanged
    }
    
    // MARK: - Persistence Tests
    
    func testSettingsPersistence() {
        // Given
        manager.bufferMode = .queue
        manager.maxBufferSize = 175
        manager.enableNotifications = true
        
        // When - Create new instance (simulating app restart)
        let newManager = SettingsManager.shared
        
        // Then
        XCTAssertEqual(newManager.bufferMode, .queue)
        XCTAssertEqual(newManager.maxBufferSize, 175)
        XCTAssertTrue(newManager.enableNotifications)
    }
}

// MARK: - AppTheme Tests

extension SettingsManagerTests {
    func testAppThemeDisplayNames() {
        XCTAssertEqual(AppTheme.system.displayName, "System")
        XCTAssertEqual(AppTheme.light.displayName, "Light")
        XCTAssertEqual(AppTheme.dark.displayName, "Dark")
    }
    
    func testAppThemeAllCases() {
        let allCases = AppTheme.allCases
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.system))
        XCTAssertTrue(allCases.contains(.light))
        XCTAssertTrue(allCases.contains(.dark))
    }
}