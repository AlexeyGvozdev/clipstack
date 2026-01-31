//
//  AppDelegate.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 30.01.2026.
//

import Cocoa
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    
    // Core components
    private let clipBuffer = ClipBuffer()
    private let clipboardMonitor = ClipboardMonitor()
    private let hotkeyManager = HotkeyManager()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupClipboardMonitoring()
        setupHotkeys()
        requestNotificationPermissions()
    }
    
    private func setupClipboardMonitoring() {
        clipboardMonitor.delegate = self
        clipboardMonitor.securityDelegate = self
        clipboardMonitor.startMonitoring()
    }
    
    private func setupHotkeys() {
        hotkeyManager.delegate = self
        hotkeyManager.registerDefaultHotkeys()
    }
    
    private func requestNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    private func showNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "ClipStack")
            button.action = #selector(togglePopover)
        }
        
        constructMenu()
    }
    
    private func constructMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "ClipStack", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc private func togglePopover() {
        // TODO: Implement popover toggle
    }
    
    @objc private func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - ClipboardMonitorDelegate

extension AppDelegate: ClipboardMonitorDelegate {
    func clipboardDidChange(_ item: ClipItem) {
        // Add item to buffer
        clipBuffer.push(item)
        
        // Update menu bar icon badge with count
        updateMenuBarBadge()
    }
    
    private func updateMenuBarBadge() {
        if let button = statusItem?.button {
            let count = clipBuffer.count
            button.title = count > 0 ? "📋 [\(count)]" : "📋"
        }
    }
}

// MARK: - HotkeyManagerDelegate

extension AppDelegate: HotkeyManagerDelegate {
    func hotkeyPressed(_ identifier: HotkeyManager.HotkeyIdentifier) {
        switch identifier {
        case .popFirst:
            handlePopFirst()
        case .popLast:
            handlePopLast()
        case .toggleMode:
            handleToggleMode()
        case .showBuffer:
            handleShowBuffer()
        case .clearBuffer:
            handleClearBuffer()
        }
    }
    
    // MARK: - Hotkey Actions
    
    private func handlePopFirst() {
        guard let item = clipBuffer.pop() else {
            print("Buffer is empty, nothing to pop")
            return
        }
        
        // Copy to clipboard and paste
        clipboardMonitor.stopMonitoring()
        
        // Use paste method which handles clipboard and simulates Cmd+V
        clipboardMonitor.paste(item.content)
        
        // Resume monitoring after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.clipboardMonitor.startMonitoring()
        }
        
        updateMenuBarBadge()
        print("Popped first item: \(item.preview)")
    }
    
    private func handlePopLast() {
        guard let item = clipBuffer.popLast() else {
            print("Buffer is empty, nothing to pop")
            return
        }
        
        // Copy to clipboard and paste
        clipboardMonitor.stopMonitoring()
        
        // Use paste method which handles clipboard and simulates Cmd+V
        clipboardMonitor.paste(item.content)
        
        // Resume monitoring after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.clipboardMonitor.startMonitoring()
        }
        
        updateMenuBarBadge()
        print("Popped last item: \(item.preview)")
    }
    
    private func handleToggleMode() {
        clipBuffer.toggleMode()
        let newMode = clipBuffer.mode
        
        // Show notification about mode change
        showNotification(
            title: "ClipStack Mode Changed",
            body: "Switched to \(newMode.displayName) mode"
        )
        
        print("Mode toggled to: \(newMode.displayName)")
    }
    
    private func handleShowBuffer() {
        // TODO: Implement buffer preview window in Stage 10
        print("Show buffer preview (not implemented yet)")
        
        // For now, print buffer contents to console
        print("Buffer contents (\(clipBuffer.count) items):")
        for (index, item) in clipBuffer.items.enumerated() {
            print("\(index + 1). [\(item.contentType)] \(item.preview)")
        }
    }
    
    private func handleClearBuffer() {
        let count = clipBuffer.count
        clipBuffer.clear()
        updateMenuBarBadge()
        
        // Show notification about clearing
        showNotification(
            title: "ClipStack Buffer Cleared",
            body: "Removed \(count) item(s) from buffer"
        )
        
        print("Buffer cleared: \(count) items removed")
    }
}

// MARK: - ClipboardSecurityDelegate

extension AppDelegate: ClipboardSecurityDelegate {
    func didBlockSensitiveData(pattern: SecurityFilter.SensitivePattern?) {
        let patternName = pattern?.description ?? "Unknown"
        
        // Show notification about blocked sensitive data
        showNotification(
            title: "🔒 Sensitive Data Blocked",
            body: "Detected and blocked: \(patternName)"
        )
        
        print("Blocked sensitive data: \(patternName)")
    }
}