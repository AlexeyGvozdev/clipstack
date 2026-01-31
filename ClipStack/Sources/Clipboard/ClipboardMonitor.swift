//
//  ClipboardMonitor.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 30.01.2026.
//

import AppKit
import Combine

/// Monitors system clipboard for changes
final class ClipboardMonitor: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var lastCopiedItem: ClipItem?
    
    // MARK: - Properties
    
    private let pasteboard = NSPasteboard.general
    private var changeCount: Int
    private var timer: Timer?
    private let pollingInterval: TimeInterval
    private let securityFilter: SecurityFilter
    private let blacklistManager: BlacklistManager
    private let settingsManager: SettingsManager
    
    weak var delegate: ClipboardMonitorDelegate?
    var securityDelegate: ClipboardSecurityDelegate?
    var blacklistDelegate: ClipboardBlacklistDelegate?
    
    // MARK: - Initialization
    
    init(
        pollingInterval: TimeInterval = 0.5,
        securityFilter: SecurityFilter = SecurityFilter(),
        blacklistManager: BlacklistManager = BlacklistManager(),
        settingsManager: SettingsManager = .shared
    ) {
        self.pollingInterval = pollingInterval
        self.securityFilter = securityFilter
        self.blacklistManager = blacklistManager
        self.settingsManager = settingsManager
        self.changeCount = pasteboard.changeCount
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Public Methods
    
    /// Start monitoring clipboard changes
    func startMonitoring() {
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(
            withTimeInterval: pollingInterval,
            repeats: true
        ) { [weak self] _ in
            self?.checkForChanges()
        }
        
        // Add to run loop to ensure it works in all modes
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    /// Stop monitoring clipboard changes
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Paste content to clipboard and simulate Cmd+V
    func paste(_ content: String) {
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
        
        // Update change count to avoid detecting our own paste
        changeCount = pasteboard.changeCount
        
        // Simulate Cmd+V
        simulatePaste()
    }
    
    // MARK: - Private Methods
    
    private func checkForChanges() {
        let currentChangeCount = pasteboard.changeCount
        
        guard currentChangeCount != changeCount else { return }
        
        changeCount = currentChangeCount
        
        guard let string = pasteboard.string(forType: .string),
              !string.isEmpty else { return }
        
        // Check for sensitive data if enabled
        if settingsManager.enableSecurityFilter {
            let sensitiveCheck = securityFilter.isSensitive(string)
            if sensitiveCheck.isSensitive {
                print("Blocked sensitive data: \(sensitiveCheck.detectedPattern?.description ?? "unknown")")
                securityDelegate?.didBlockSensitiveData(pattern: sensitiveCheck.detectedPattern)
                return
            }
        }
        
        // Check blacklist if enabled
        if settingsManager.enableBlacklist {
            let blacklistCheck = blacklistManager.isBlacklisted(string)
            if blacklistCheck.blocked {
                print("Blocked by blacklist: \(blacklistCheck.matchedRule?.description ?? blacklistCheck.matchedRule?.pattern ?? "unknown")")
                blacklistDelegate?.didBlockByBlacklist(rule: blacklistCheck.matchedRule)
                return
            }
        }
        
        let item = ClipItem(
            content: string,
            timestamp: Date(),
            sourceApp: getActiveAppName(),
            contentType: detectContentType(string)
        )
        
        lastCopiedItem = item
        delegate?.clipboardDidChange(item)
    }
    
    private func detectContentType(_ content: String) -> ClipItem.ContentType {
        // URL detection
        if content.starts(with: "http://") || content.starts(with: "https://") {
            return .url
        }
        
        // Email detection
        if content.contains("@") && content.contains(".") && !content.contains(" ") {
            let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            if let regex = try? NSRegularExpression(pattern: emailPattern),
               regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)) != nil {
                return .email
            }
        }
        
        // Code detection (simple heuristics)
        let codeIndicators = ["{", "}", "func", "class", "def", "import", "const", "let", "var"]
        if codeIndicators.contains(where: { content.contains($0) }) {
            return .code
        }
        
        return .plainText
    }
    
    private func getActiveAppName() -> String? {
        return NSWorkspace.shared.frontmostApplication?.localizedName
    }
    
    private func simulatePaste() {
        // Create Cmd+V key event
        let source = CGEventSource(stateID: .hidSystemState)
        
        // Key code for 'V' is 0x09
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        
        // Add Command modifier
        keyDown?.flags = .maskCommand
        keyUp?.flags = .maskCommand
        
        // Post events
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
}

// MARK: - ClipboardMonitorDelegate

protocol ClipboardMonitorDelegate: AnyObject {
    /// Called when clipboard content changes
    /// - Parameter item: The new clipboard item
    func clipboardDidChange(_ item: ClipItem)
}

// MARK: - ClipboardSecurityDelegate

protocol ClipboardSecurityDelegate: AnyObject {
    /// Called when sensitive data is detected and blocked
    /// - Parameter pattern: The type of sensitive pattern detected
    func didBlockSensitiveData(pattern: SecurityFilter.SensitivePattern?)
}

// MARK: - ClipboardBlacklistDelegate

protocol ClipboardBlacklistDelegate: AnyObject {
    /// Called when content is blocked by blacklist
    /// - Parameter rule: The blacklist rule that matched
    func didBlockByBlacklist(rule: BlacklistRule?)
}