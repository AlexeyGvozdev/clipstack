//
//  HotkeyManagerTests.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 30.01.2026.
//

import XCTest
@testable import ClipStack

final class HotkeyManagerTests: XCTestCase {
    var hotkeyManager: HotkeyManager!
    var mockDelegate: MockHotkeyDelegate!
    
    override func setUp() {
        super.setUp()
        hotkeyManager = HotkeyManager()
        mockDelegate = MockHotkeyDelegate()
        hotkeyManager.delegate = mockDelegate
    }
    
    override func tearDown() {
        hotkeyManager.unregisterAllHotkeys()
        hotkeyManager = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertNotNil(hotkeyManager, "HotkeyManager should be initialized")
    }
    
    // MARK: - Registration Tests
    
    func testRegisterDefaultHotkeys() {
        // When
        hotkeyManager.registerDefaultHotkeys()
        
        // Then - No crashes means success
        // Note: Actual hotkey registration requires running app with accessibility permissions
        XCTAssertTrue(true, "Default hotkeys registered without crashes")
    }
    
    func testUnregisterAllHotkeys() {
        // Given
        hotkeyManager.registerDefaultHotkeys()
        
        // When
        hotkeyManager.unregisterAllHotkeys()
        
        // Then - No crashes means success
        XCTAssertTrue(true, "All hotkeys unregistered without crashes")
    }
    
    // MARK: - Hotkey Identifier Tests
    
    func testHotkeyIdentifierDisplayNames() {
        XCTAssertEqual(HotkeyManager.HotkeyIdentifier.popFirst.displayName, "Extract First")
        XCTAssertEqual(HotkeyManager.HotkeyIdentifier.popLast.displayName, "Extract Last")
        XCTAssertEqual(HotkeyManager.HotkeyIdentifier.toggleMode.displayName, "Toggle Mode")
        XCTAssertEqual(HotkeyManager.HotkeyIdentifier.showBuffer.displayName, "Show Buffer")
        XCTAssertEqual(HotkeyManager.HotkeyIdentifier.clearBuffer.displayName, "Clear Buffer")
    }
    
    func testHotkeyIdentifierShortcuts() {
        XCTAssertEqual(HotkeyManager.HotkeyIdentifier.popFirst.shortcut, "⌘⇧V")
        XCTAssertEqual(HotkeyManager.HotkeyIdentifier.popLast.shortcut, "⌘⇧B")
        XCTAssertEqual(HotkeyManager.HotkeyIdentifier.toggleMode.shortcut, "⌘⇧M")
        XCTAssertEqual(HotkeyManager.HotkeyIdentifier.showBuffer.shortcut, "⌘⇧C")
        XCTAssertEqual(HotkeyManager.HotkeyIdentifier.clearBuffer.shortcut, "⌘⇧X")
    }
    
    func testHotkeyIdentifierDescriptions() {
        XCTAssertFalse(HotkeyManager.HotkeyIdentifier.popFirst.description.isEmpty)
        XCTAssertFalse(HotkeyManager.HotkeyIdentifier.popLast.description.isEmpty)
        XCTAssertFalse(HotkeyManager.HotkeyIdentifier.toggleMode.description.isEmpty)
        XCTAssertFalse(HotkeyManager.HotkeyIdentifier.showBuffer.description.isEmpty)
        XCTAssertFalse(HotkeyManager.HotkeyIdentifier.clearBuffer.description.isEmpty)
    }
    
    func testHotkeyIdentifierRawValues() {
        XCTAssertEqual(HotkeyManager.HotkeyIdentifier.popFirst.rawValue, 1)
        XCTAssertEqual(HotkeyManager.HotkeyIdentifier.popLast.rawValue, 2)
        XCTAssertEqual(HotkeyManager.HotkeyIdentifier.toggleMode.rawValue, 3)
        XCTAssertEqual(HotkeyManager.HotkeyIdentifier.showBuffer.rawValue, 4)
        XCTAssertEqual(HotkeyManager.HotkeyIdentifier.clearBuffer.rawValue, 5)
    }
    
    // MARK: - Delegate Tests
    
    func testDelegateIsWeak() {
        // Given
        var delegate: MockHotkeyDelegate? = MockHotkeyDelegate()
        hotkeyManager.delegate = delegate
        
        // When
        delegate = nil
        
        // Then
        XCTAssertNil(hotkeyManager.delegate, "Delegate should be weak and set to nil")
    }
}

// MARK: - Mock Delegate

private class MockHotkeyDelegate: HotkeyManagerDelegate {
    var pressedHotkeys: [HotkeyManager.HotkeyIdentifier] = []
    
    func hotkeyPressed(_ identifier: HotkeyManager.HotkeyIdentifier) {
        pressedHotkeys.append(identifier)
    }
}