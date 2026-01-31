//
//  PreviewWindowController.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 31.01.2026.
//

import Cocoa
import SwiftUI
import UserNotifications

/// Window controller for the clipboard preview window
final class PreviewWindowController: NSWindowController {
    private let clipBuffer: ClipBuffer
    private let clipboardMonitor: ClipboardMonitor
    
    // Callbacks
    var onCopyItem: ((ClipItem) -> Void)?
    var onDeleteItem: ((ClipItem) -> Void)?
    var onClearAll: (() -> Void)?
    
    init(clipBuffer: ClipBuffer, clipboardMonitor: ClipboardMonitor) {
        self.clipBuffer = clipBuffer
        self.clipboardMonitor = clipboardMonitor
        
        // Create window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 500),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        super.init(window: window)
        
        setupWindow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupWindow() {
        guard let window = window else { return }
        
        window.title = "ClipStack History"
        window.center()
        window.setFrameAutosaveName("PreviewWindow")
        window.isReleasedWhenClosed = false
        
        // Create SwiftUI view
        let previewView = PreviewView(
            clipBuffer: clipBuffer,
            onCopyItem: { [weak self] item in
                self?.handleCopyItem(item)
            },
            onDeleteItem: { [weak self] item in
                self?.handleDeleteItem(item)
            },
            onClearAll: { [weak self] in
                self?.handleClearAll()
            }
        )
        
        // Set content view
        window.contentView = NSHostingView(rootView: previewView)
        
        // Set minimum size
        window.minSize = NSSize(width: 600, height: 400)
    }
    
    // MARK: - Public Methods
    
    /// Show the preview window
    func show() {
        guard let window = window else { return }
        
        if !window.isVisible {
            window.center()
        }
        
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    /// Hide the preview window
    func hide() {
        window?.orderOut(nil)
    }
    
    /// Toggle window visibility
    func toggle() {
        if window?.isVisible == true {
            hide()
        } else {
            show()
        }
    }
    
    // MARK: - Private Methods
    
    private func handleCopyItem(_ item: ClipItem) {
        // Stop monitoring temporarily to avoid re-adding the item
        clipboardMonitor.stopMonitoring()
        
        // Copy to clipboard and paste
        clipboardMonitor.paste(item.content)
        
        // Resume monitoring after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.clipboardMonitor.startMonitoring()
        }
        
        // Call callback if set
        onCopyItem?(item)
        
        // Show notification
        showNotification(title: "Copied to Clipboard", body: item.preview)
    }
    
    private func handleDeleteItem(_ item: ClipItem) {
        clipBuffer.remove(id: item.id)
        
        // Call callback if set
        onDeleteItem?(item)
        
        // Show notification
        showNotification(title: "Item Deleted", body: "Removed from clipboard history")
    }
    
    private func handleClearAll() {
        let count = clipBuffer.count
        clipBuffer.clear()
        
        // Call callback if set
        onClearAll?()
        
        // Show notification
        showNotification(
            title: "History Cleared",
            body: "Removed \(count) item(s) from clipboard history"
        )
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
}