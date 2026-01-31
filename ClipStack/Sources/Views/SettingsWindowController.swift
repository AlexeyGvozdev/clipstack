//
//  SettingsWindowController.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 31.01.2026.
//

import Cocoa
import SwiftUI

/// Window controller for the settings window
final class SettingsWindowController: NSWindowController {
    
    init() {
        // Create window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 450),
            styleMask: [.titled, .closable, .miniaturizable],
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
        
        window.title = "ClipStack Settings"
        window.center()
        window.setFrameAutosaveName("SettingsWindow")
        window.isReleasedWhenClosed = false
        
        // Create SwiftUI view
        let settingsView = SettingsView()
        
        // Set content view
        window.contentView = NSHostingView(rootView: settingsView)
        
        // Set minimum size
        window.minSize = NSSize(width: 600, height: 450)
    }
    
    // MARK: - Public Methods
    
    /// Show the settings window
    func show() {
        guard let window = window else { return }
        
        if !window.isVisible {
            window.center()
        }
        
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    /// Hide the settings window
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
}