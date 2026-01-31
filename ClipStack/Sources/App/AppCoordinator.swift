//
//  AppCoordinator.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 31.01.2026.
//

import Foundation
import Combine
import UserNotifications
import Cocoa

/// Central coordinator for managing all app modules and their interactions
final class AppCoordinator: ObservableObject {
    // MARK: - Published Properties
    
    @Published var isInitialized = false
    @Published var initializationError: Error?
    
    // MARK: - Core Components
    
    private let settingsManager = SettingsManager.shared
    private let coreDataManager = CoreDataManager.shared
    private lazy var autoClearManager: AutoClearManager = {
        AutoClearManager(settingsManager: settingsManager)
    }()
    private lazy var clipBuffer: ClipBuffer = {
        ClipBuffer(
            autoClearManager: autoClearManager,
            coreDataManager: coreDataManager,
            settingsManager: settingsManager
        )
    }()
    private let blacklistManager = BlacklistManager()
    private lazy var clipboardMonitor: ClipboardMonitor = {
        ClipboardMonitor(
            blacklistManager: blacklistManager,
            settingsManager: settingsManager
        )
    }()
    private let hotkeyManager = HotkeyManager()
    
    // MARK: - UI Components
    
    private lazy var previewWindowController: PreviewWindowController = {
        let controller = PreviewWindowController(
            clipBuffer: clipBuffer,
            clipboardMonitor: clipboardMonitor
        )
        setupPreviewWindowCallbacks(controller)
        return controller
    }()
    
    private lazy var settingsWindowController: SettingsWindowController = {
        SettingsWindowController()
    }()
    
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    private var statusItem: NSStatusItem?
    
    // MARK: - Initialization
    
    init() {
        setupBindings()
        initialize()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Public API
    
    /// Initialize all modules
    func initialize() {
        do {
            // Initialize Core Data
            try initializeCoreData()
            
            // Setup clipboard monitoring
            setupClipboardMonitoring()
            
            // Setup hotkeys
            setupHotkeys()
            
            // Setup menu bar
            setupMenuBar()
            
            // Start auto-clear if enabled
            setupAutoClear()
            
            // Request notification permissions (delayed to avoid bundle issues)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.requestNotificationPermissions()
            }
            
            isInitialized = true
            print("✅ AppCoordinator initialized successfully")
            
        } catch {
            initializationError = error
            print("❌ Failed to initialize AppCoordinator: \(error)")
        }
    }
    
    /// Show preview window
    func showPreviewWindow() {
        previewWindowController.show()
    }
    
    /// Show settings window
    func showSettingsWindow() {
        settingsWindowController.show()
    }
    
    /// Clear buffer
    func clearBuffer() {
        let count = clipBuffer.count
        clipBuffer.clear()
        updateMenuBarBadge()
        
        // Show notification if enabled
        if settingsManager.enableNotifications {
            showNotification(
                title: "ClipStack Buffer Cleared",
                body: "Removed \(count) item(s) from buffer"
            )
        }
    }
    
    /// Toggle buffer mode
    func toggleBufferMode() {
        clipBuffer.toggleMode()
        let newMode = clipBuffer.mode
        
        // Show notification if enabled
        if settingsManager.enableNotifications {
            showNotification(
                title: "ClipStack Mode Changed",
                body: "Switched to \(newMode.displayName) mode"
            )
        }
    }
    
    // MARK: - Private Methods
    
    private func initializeCoreData() throws {
        // Test Core Data connection
        _ = try coreDataManager.getItemCount()
        print("✅ Core Data initialized")
    }
    
    private func setupClipboardMonitoring() {
        clipboardMonitor.delegate = self
        clipboardMonitor.securityDelegate = self
        clipboardMonitor.blacklistDelegate = self
        clipboardMonitor.startMonitoring()
        print("✅ Clipboard monitoring started")
    }
    
    private func setupHotkeys() {
        hotkeyManager.delegate = self
        hotkeyManager.registerDefaultHotkeys()
        print("✅ Hotkeys registered")
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.title = "📋"
        }
        
        constructMenu()
        updateMenuBarBadge()
        print("✅ Menu bar setup completed")
    }
    
    private func setupAutoClear() {
        autoClearManager.start()
        print("✅ Auto-clear manager started")
    }
    
    private func setupBindings() {
        // Watch for buffer changes
        clipBuffer.objectWillChange
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.objectWillChange.send()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupPreviewWindowCallbacks(_ controller: PreviewWindowController) {
        controller.onCopyItem = { [weak self] item in
            self?.updateMenuBarBadge()
        }
        
        controller.onDeleteItem = { [weak self] item in
            self?.updateMenuBarBadge()
        }
        
        controller.onClearAll = { [weak self] in
            self?.updateMenuBarBadge()
        }
    }
    
    private func constructMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "ClipStack", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        let showBufferItem = NSMenuItem(title: "Show Buffer", action: #selector(showBuffer), keyEquivalent: "")
        showBufferItem.target = self
        menu.addItem(showBufferItem)
        
        let clearBufferItem = NSMenuItem(title: "Clear Buffer", action: #selector(clearBufferAction), keyEquivalent: "")
        clearBufferItem.target = self
        menu.addItem(clearBufferItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    private func updateMenuBarBadge() {
        if let button = statusItem?.button {
            let count = clipBuffer.count
            button.title = count > 0 ? "📋 [\(count)]" : "📋"
        }
    }
    
    private func requestNotificationPermissions() {
        // Check if we're in a proper bundle environment
        guard Bundle.main.bundleIdentifier != nil else {
            print("Skipping notification permissions - not in proper bundle environment")
            return
        }
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            } else {
                print("Notification permissions: \(granted ? "granted" : "denied")")
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
    
    private func cleanup() {
        clipboardMonitor.stopMonitoring()
        autoClearManager.stop()
        hotkeyManager.unregisterAllHotkeys()
        print("🧹 AppCoordinator cleanup completed")
    }
    
    // MARK: - Menu Actions
    
    @objc private func showBuffer() {
        showPreviewWindow()
    }
    
    @objc private func clearBufferAction() {
        clearBuffer()
    }
    
    @objc private func openSettings() {
        showSettingsWindow()
    }
}

// MARK: - ClipboardMonitorDelegate

extension AppCoordinator: ClipboardMonitorDelegate {
    func clipboardDidChange(_ item: ClipItem) {
        // Add item to buffer
        clipBuffer.push(item)
        
        // Update menu bar badge
        updateMenuBarBadge()
    }
}

// MARK: - HotkeyManagerDelegate

extension AppCoordinator: HotkeyManagerDelegate {
    func hotkeyPressed(_ identifier: HotkeyManager.HotkeyIdentifier) {
        switch identifier {
        case .popFirst:
            handlePopFirst()
        case .popLast:
            handlePopLast()
        case .toggleMode:
            toggleBufferMode()
        case .showBuffer:
            showPreviewWindow()
        case .clearBuffer:
            clearBuffer()
        }
    }
    
    private func handlePopFirst() {
        guard let item = clipBuffer.pop() else {
            print("Buffer is empty, nothing to pop")
            return
        }
        
        // Copy to clipboard and paste
        clipboardMonitor.stopMonitoring()
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
        clipboardMonitor.paste(item.content)
        
        // Resume monitoring after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.clipboardMonitor.startMonitoring()
        }
        
        updateMenuBarBadge()
        print("Popped last item: \(item.preview)")
    }
}

// MARK: - ClipboardSecurityDelegate

extension AppCoordinator: ClipboardSecurityDelegate {
    func didBlockSensitiveData(pattern: SecurityFilter.SensitivePattern?) {
        let patternName = pattern?.description ?? "Unknown"
        
        // Show notification if enabled
        if settingsManager.enableNotifications {
            showNotification(
                title: "🔒 Sensitive Data Blocked",
                body: "Detected and blocked: \(patternName)"
            )
        }
        
        print("Blocked sensitive data: \(patternName)")
    }
}

// MARK: - ClipboardBlacklistDelegate

extension AppCoordinator: ClipboardBlacklistDelegate {
    func didBlockByBlacklist(rule: BlacklistRule?) {
        let ruleName = rule?.description ?? rule?.pattern ?? "Unknown rule"
        
        // Show notification if enabled
        if settingsManager.enableNotifications {
            showNotification(
                title: "🚫 Content Blocked",
                body: "Blocked by blacklist: \(ruleName)"
            )
        }
        
        print("Blocked by blacklist: \(ruleName)")
    }
}