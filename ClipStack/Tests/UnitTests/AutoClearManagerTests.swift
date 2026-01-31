//
//  AutoClearManagerTests.swift
//  ClipStackTests
//
//  Created by ClipStack on 2026-01-31.
//

import XCTest
@testable import ClipStack

final class AutoClearManagerTests: XCTestCase {
    var manager: AutoClearManager!
    var delegate: MockAutoClearDelegate!
    
    override func setUp() {
        super.setUp()
        delegate = MockAutoClearDelegate()
        
        var settings = AutoClearSettings()
        settings.isEnabled = true
        settings.interval = 2 // 2 seconds for testing
        settings.notifyBeforeClear = false // Disable notifications for tests
        
        manager = AutoClearManager(settings: settings)
        manager.delegate = delegate
    }
    
    override func tearDown() {
        manager.stop()
        manager = nil
        delegate = nil
        super.tearDown()
    }
    
    // MARK: - Settings Tests
    
    func testDefaultSettings() {
        let settings = AutoClearSettings()
        
        XCTAssertFalse(settings.isEnabled)
        XCTAssertEqual(settings.interval, 1800) // 30 minutes
        XCTAssertTrue(settings.notifyBeforeClear)
        XCTAssertEqual(settings.notificationTime, 60)
        XCTAssertFalse(settings.clearOnlyOldItems)
        XCTAssertEqual(settings.itemMaxAge, 3600)
        XCTAssertTrue(settings.resetTimerOnActivity)
    }
    
    func testPresetSettings() {
        let quickWork = AutoClearSettings.quickWork
        XCTAssertTrue(quickWork.isEnabled)
        XCTAssertEqual(quickWork.interval, 900) // 15 minutes
        
        let confidential = AutoClearSettings.confidential
        XCTAssertTrue(confidential.isEnabled)
        XCTAssertEqual(confidential.interval, 300) // 5 minutes
        XCTAssertFalse(confidential.notifyBeforeClear)
        
        let longSession = AutoClearSettings.longSession
        XCTAssertTrue(longSession.isEnabled)
        XCTAssertEqual(longSession.interval, 7200) // 2 hours
        XCTAssertTrue(longSession.clearOnlyOldItems)
        
        let disabled = AutoClearSettings.disabled
        XCTAssertFalse(disabled.isEnabled)
    }
    
    func testPresetIntervals() {
        XCTAssertEqual(AutoClearSettings.Preset.fiveMinutes.interval, 300)
        XCTAssertEqual(AutoClearSettings.Preset.fifteenMinutes.interval, 900)
        XCTAssertEqual(AutoClearSettings.Preset.thirtyMinutes.interval, 1800)
        XCTAssertEqual(AutoClearSettings.Preset.oneHour.interval, 3600)
        XCTAssertEqual(AutoClearSettings.Preset.twoHours.interval, 7200)
        XCTAssertEqual(AutoClearSettings.Preset.fourHours.interval, 14400)
        XCTAssertNil(AutoClearSettings.Preset.never.interval)
    }
    
    // MARK: - Manager Tests
    
    func testStartStop() {
        manager.start()
        XCTAssertTrue(manager.isCountingDown)
        XCTAssertNotNil(manager.timeUntilClear)
        
        manager.stop()
        XCTAssertFalse(manager.isCountingDown)
        XCTAssertNil(manager.timeUntilClear)
    }
    
    func testUpdateSettings() {
        var newSettings = manager.settings
        newSettings.interval = 5
        
        manager.updateSettings(newSettings)
        
        XCTAssertEqual(manager.settings.interval, 5)
    }
    
    func testDisableAutoClear() {
        manager.start()
        XCTAssertTrue(manager.isCountingDown)
        
        var newSettings = manager.settings
        newSettings.isEnabled = false
        manager.updateSettings(newSettings)
        
        XCTAssertFalse(manager.isCountingDown)
    }
    
    func testHandleActivity() {
        manager.start()
        
        // Wait a bit
        Thread.sleep(forTimeInterval: 0.5)
        
        let timeBefore = manager.timeUntilClear
        
        // Handle activity should reset timer
        manager.handleActivity()
        
        let timeAfter = manager.timeUntilClear
        
        // Time should be reset (closer to interval)
        XCTAssertNotNil(timeBefore)
        XCTAssertNotNil(timeAfter)
        if let before = timeBefore, let after = timeAfter {
            XCTAssertGreaterThan(after, before)
        }
    }
    
    func testFormattedTime() {
        manager.start()
        
        let formatted = manager.formattedTimeUntilClear
        
        // Should be in format MM:SS
        XCTAssertTrue(formatted.contains(":"))
        XCTAssertEqual(formatted.count, 5) // "00:02" or similar
    }
    
    // MARK: - Delegate Tests
    
    func testClearBuffer() {
        manager.clearNow()
        
        XCTAssertTrue(delegate.clearBufferCalled)
        XCTAssertFalse(delegate.clearOldItemsCalled)
    }
    
    func testClearOnlyOldItems() {
        var settings = manager.settings
        settings.clearOnlyOldItems = true
        settings.itemMaxAge = 60
        manager.updateSettings(settings)
        
        manager.clearNow()
        
        XCTAssertFalse(delegate.clearBufferCalled)
        XCTAssertTrue(delegate.clearOldItemsCalled)
        XCTAssertEqual(delegate.maxAge, 60)
    }
}

// MARK: - Mock Delegate

class MockAutoClearDelegate: AutoClearManagerDelegate {
    var clearBufferCalled = false
    var clearOldItemsCalled = false
    var maxAge: TimeInterval = 0
    var itemsCleared = 0
    
    func autoClearShouldClearBuffer() -> Int {
        clearBufferCalled = true
        itemsCleared = 10 // Simulate 10 items cleared
        return itemsCleared
    }
    
    func autoClearShouldClearOldItems(olderThan age: TimeInterval) -> Int {
        clearOldItemsCalled = true
        maxAge = age
        itemsCleared = 5 // Simulate 5 old items cleared
        return itemsCleared
    }
}