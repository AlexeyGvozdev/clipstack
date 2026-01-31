//
//  SettingsManager.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 31.01.2026.
//

import Foundation

/// Manager for application settings using UserDefaults
final class SettingsManager {
    // MARK: - Singleton
    
    static let shared = SettingsManager()
    
    // MARK: - Keys
    
    private enum Keys {
        static let bufferMode = "clipstack.bufferMode"
        static let maxBufferSize = "clipstack.maxBufferSize"
        static let enableNotifications = "clipstack.enableNotifications"
        static let enableAutoSave = "clipstack.enableAutoSave"
        static let autoSaveInterval = "clipstack.autoSaveInterval"
        static let enableSecurityFilter = "clipstack.enableSecurityFilter"
        static let enableBlacklist = "clipstack.enableBlacklist"
        static let enableAutoClear = "clipstack.enableAutoClear"
        static let launchAtLogin = "clipstack.launchAtLogin"
        static let showInDock = "clipstack.showInDock"
        static let theme = "clipstack.theme"
    }
    
    // MARK: - Properties
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Buffer Settings
    
    /// Current buffer mode (Stack or Queue)
    var bufferMode: BufferMode {
        get {
            guard let rawValue = defaults.string(forKey: Keys.bufferMode),
                  let mode = BufferMode(rawValue: rawValue) else {
                return .stack // Default
            }
            return mode
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.bufferMode)
        }
    }
    
    /// Maximum buffer size
    var maxBufferSize: Int {
        get {
            let size = defaults.integer(forKey: Keys.maxBufferSize)
            return size > 0 ? size : 100 // Default: 100
        }
        set {
            defaults.set(newValue, forKey: Keys.maxBufferSize)
        }
    }
    
    // MARK: - Notification Settings
    
    /// Enable/disable notifications
    var enableNotifications: Bool {
        get {
            defaults.bool(forKey: Keys.enableNotifications)
        }
        set {
            defaults.set(newValue, forKey: Keys.enableNotifications)
        }
    }
    
    // MARK: - Auto-Save Settings
    
    /// Enable/disable auto-save to Core Data
    var enableAutoSave: Bool {
        get {
            // Default: true
            if defaults.object(forKey: Keys.enableAutoSave) == nil {
                return true
            }
            return defaults.bool(forKey: Keys.enableAutoSave)
        }
        set {
            defaults.set(newValue, forKey: Keys.enableAutoSave)
        }
    }
    
    /// Auto-save interval in seconds
    var autoSaveInterval: TimeInterval {
        get {
            let interval = defaults.double(forKey: Keys.autoSaveInterval)
            return interval > 0 ? interval : 30.0 // Default: 30 seconds
        }
        set {
            defaults.set(newValue, forKey: Keys.autoSaveInterval)
        }
    }
    
    // MARK: - Security Settings
    
    /// Enable/disable security filter
    var enableSecurityFilter: Bool {
        get {
            // Default: true
            if defaults.object(forKey: Keys.enableSecurityFilter) == nil {
                return true
            }
            return defaults.bool(forKey: Keys.enableSecurityFilter)
        }
        set {
            defaults.set(newValue, forKey: Keys.enableSecurityFilter)
        }
    }
    
    /// Enable/disable blacklist
    var enableBlacklist: Bool {
        get {
            // Default: true
            if defaults.object(forKey: Keys.enableBlacklist) == nil {
                return true
            }
            return defaults.bool(forKey: Keys.enableBlacklist)
        }
        set {
            defaults.set(newValue, forKey: Keys.enableBlacklist)
        }
    }
    
    /// Enable/disable auto-clear
    var enableAutoClear: Bool {
        get {
            defaults.bool(forKey: Keys.enableAutoClear)
        }
        set {
            defaults.set(newValue, forKey: Keys.enableAutoClear)
        }
    }
    
    // MARK: - App Settings
    
    /// Launch at login
    var launchAtLogin: Bool {
        get {
            defaults.bool(forKey: Keys.launchAtLogin)
        }
        set {
            defaults.set(newValue, forKey: Keys.launchAtLogin)
        }
    }
    
    /// Show app in Dock
    var showInDock: Bool {
        get {
            defaults.bool(forKey: Keys.showInDock)
        }
        set {
            defaults.set(newValue, forKey: Keys.showInDock)
        }
    }
    
    /// App theme
    var theme: AppTheme {
        get {
            guard let rawValue = defaults.string(forKey: Keys.theme),
                  let theme = AppTheme(rawValue: rawValue) else {
                return .system // Default
            }
            return theme
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.theme)
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        registerDefaults()
    }
    
    // MARK: - Default Values
    
    /// Register default values
    private func registerDefaults() {
        let defaults: [String: Any] = [
            Keys.bufferMode: BufferMode.stack.rawValue,
            Keys.maxBufferSize: 100,
            Keys.enableNotifications: false,
            Keys.enableAutoSave: true,
            Keys.autoSaveInterval: 30.0,
            Keys.enableSecurityFilter: true,
            Keys.enableBlacklist: true,
            Keys.enableAutoClear: false,
            Keys.launchAtLogin: false,
            Keys.showInDock: false,
            Keys.theme: AppTheme.system.rawValue
        ]
        
        self.defaults.register(defaults: defaults)
    }
    
    // MARK: - Reset
    
    /// Reset all settings to defaults
    func resetToDefaults() {
        let domain = Bundle.main.bundleIdentifier ?? "com.clipstack"
        defaults.removePersistentDomain(forName: domain)
        registerDefaults()
    }
    
    // MARK: - Export/Import
    
    /// Export settings to dictionary
    func exportSettings() -> [String: Any] {
        return [
            "bufferMode": bufferMode.rawValue,
            "maxBufferSize": maxBufferSize,
            "enableNotifications": enableNotifications,
            "enableAutoSave": enableAutoSave,
            "autoSaveInterval": autoSaveInterval,
            "enableSecurityFilter": enableSecurityFilter,
            "enableBlacklist": enableBlacklist,
            "enableAutoClear": enableAutoClear,
            "launchAtLogin": launchAtLogin,
            "showInDock": showInDock,
            "theme": theme.rawValue
        ]
    }
    
    /// Import settings from dictionary
    func importSettings(_ settings: [String: Any]) {
        if let modeString = settings["bufferMode"] as? String,
           let mode = BufferMode(rawValue: modeString) {
            bufferMode = mode
        }
        
        if let size = settings["maxBufferSize"] as? Int {
            maxBufferSize = size
        }
        
        if let enabled = settings["enableNotifications"] as? Bool {
            enableNotifications = enabled
        }
        
        if let enabled = settings["enableAutoSave"] as? Bool {
            enableAutoSave = enabled
        }
        
        if let interval = settings["autoSaveInterval"] as? TimeInterval {
            autoSaveInterval = interval
        }
        
        if let enabled = settings["enableSecurityFilter"] as? Bool {
            enableSecurityFilter = enabled
        }
        
        if let enabled = settings["enableBlacklist"] as? Bool {
            enableBlacklist = enabled
        }
        
        if let enabled = settings["enableAutoClear"] as? Bool {
            enableAutoClear = enabled
        }
        
        if let enabled = settings["launchAtLogin"] as? Bool {
            launchAtLogin = enabled
        }
        
        if let enabled = settings["showInDock"] as? Bool {
            showInDock = enabled
        }
        
        if let themeString = settings["theme"] as? String,
           let appTheme = AppTheme(rawValue: themeString) {
            theme = appTheme
        }
    }
}

// MARK: - Supporting Types

/// App theme enum
enum AppTheme: String, Codable, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}