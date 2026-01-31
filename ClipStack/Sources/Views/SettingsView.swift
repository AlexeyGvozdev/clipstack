//
//  SettingsView.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 30.01.2026.
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "gearshape.2.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.accentColor)
                    
                    Text("Settings")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .padding(20)
                .padding(.bottom, 10)
                
                // Navigation items
                VStack(spacing: 2) {
                    SettingsNavItem(
                        title: "General",
                        icon: "gear",
                        isSelected: selectedTab == 0
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = 0
                        }
                    }
                    
                    SettingsNavItem(
                        title: "Hotkeys",
                        icon: "keyboard",
                        isSelected: selectedTab == 1
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = 1
                        }
                    }
                    
                    SettingsNavItem(
                        title: "Security",
                        icon: "lock.shield",
                        isSelected: selectedTab == 2
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = 2
                        }
                    }
                    
                    SettingsNavItem(
                        title: "Blacklist",
                        icon: "xmark.circle",
                        isSelected: selectedTab == 3
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = 3
                        }
                    }
                    
                    SettingsNavItem(
                        title: "Auto-Clear",
                        icon: "clock",
                        isSelected: selectedTab == 4
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = 4
                        }
                    }
                    
                    SettingsNavItem(
                        title: "About",
                        icon: "info.circle",
                        isSelected: selectedTab == 5
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = 5
                        }
                    }
                }
                
                Spacer()
            }
            .frame(width: 200)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Content area
            Group {
                switch selectedTab {
                case 0:
                    GeneralSettingsView()
                case 1:
                    HotkeysSettingsView()
                case 2:
                    SecuritySettingsView()
                case 3:
                    BlacklistSettingsView()
                case 4:
                    AutoClearSettingsView()
                case 5:
                    AboutView()
                default:
                    GeneralSettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(width: 700, height: 500)
        .onAppear {
            // Set initial appearance
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTab = 0
            }
        }
    }
}

// MARK: - Settings Navigation Item

struct SettingsNavItem: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : .secondary)
                    .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 12)
        .padding(.vertical, 2)
    }
}

// MARK: - General Settings

struct GeneralSettingsView: View {
    @State private var bufferMode: BufferMode = SettingsManager.shared.bufferMode
    @State private var maxBufferSize: Double = Double(SettingsManager.shared.maxBufferSize)
    @State private var enableNotifications: Bool = SettingsManager.shared.enableNotifications
    @State private var launchAtLogin: Bool = SettingsManager.shared.launchAtLogin
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Buffer Settings Card
                SettingsCard(title: "Buffer Settings", icon: "list.bullet.clipboard") {
                    VStack(spacing: 20) {
                        // Mode Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Buffer Mode")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 12) {
                                ForEach([BufferMode.stack, BufferMode.queue], id: \.self) { mode in
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            bufferMode = mode
                                            SettingsManager.shared.bufferMode = mode
                                        }
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: mode.icon)
                                                .font(.system(size: 14, weight: .medium))
                                            Text(mode.displayName)
                                                .font(.system(size: 13, weight: .medium))
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(bufferMode == mode ? Color.accentColor : Color(NSColor.controlBackgroundColor))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(bufferMode == mode ? Color.clear : Color(NSColor.separatorColor), lineWidth: 1)
                                                )
                                        )
                                        .foregroundColor(bufferMode == mode ? .white : .primary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            
                            Text(bufferMode.description)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        
                        Divider()
                        
                        // Buffer Size Slider
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Max Buffer Size")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("\(Int(maxBufferSize)) items")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.accentColor)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.accentColor.opacity(0.1))
                                    .cornerRadius(6)
                            }
                            
                            Slider(value: $maxBufferSize, in: 10...500, step: 10)
                                .onChange(of: maxBufferSize) { newValue in
                                    SettingsManager.shared.maxBufferSize = Int(newValue)
                                }
                            
                            Text("Number of items to keep in history")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Notifications Card
                SettingsCard(title: "Notifications", icon: "bell") {
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Enable Notifications")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text("Show notifications for clipboard events")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $enableNotifications)
                                .onChange(of: enableNotifications) { newValue in
                                    SettingsManager.shared.enableNotifications = newValue
                                }
                                .toggleStyle(SwitchToggleStyle())
                        }
                    }
                }
                
                // Startup Card
                SettingsCard(title: "Startup", icon: "power") {
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Launch at Login")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text("Automatically start ClipStack when you log in")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $launchAtLogin)
                                .onChange(of: launchAtLogin) { newValue in
                                    SettingsManager.shared.launchAtLogin = newValue
                                }
                                .toggleStyle(SwitchToggleStyle())
                        }
                    }
                }
            }
            .padding(24)
        }
    }
}

// MARK: - Hotkeys Settings

struct HotkeysSettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Global Hotkeys").font(.headline)) {
                Text("Configure keyboard shortcuts for quick access")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("Available Hotkeys").font(.headline)) {
                VStack(alignment: .leading, spacing: 12) {
                    HotkeyRow(
                        icon: "arrow.up.doc.on.clipboard",
                        name: "Pop First",
                        shortcut: "⌘⇧V",
                        description: "Extract and paste first item from buffer"
                    )
                    
                    Divider()
                    
                    HotkeyRow(
                        icon: "arrow.down.doc.on.clipboard",
                        name: "Pop Last",
                        shortcut: "⌘⇧B",
                        description: "Extract and paste last item from buffer"
                    )
                    
                    Divider()
                    
                    HotkeyRow(
                        icon: "arrow.left.arrow.right",
                        name: "Toggle Mode",
                        shortcut: "⌘⇧M",
                        description: "Switch between Stack and Queue modes"
                    )
                    
                    Divider()
                    
                    HotkeyRow(
                        icon: "list.clipboard",
                        name: "Show History",
                        shortcut: "⌘⇧C",
                        description: "Open clipboard history window"
                    )
                    
                    Divider()
                    
                    HotkeyRow(
                        icon: "trash",
                        name: "Clear Buffer",
                        shortcut: "⌘⇧X",
                        description: "Remove all items from buffer"
                    )
                }
            }
            
            Section {
                Text("Note: Hotkey customization will be available in a future update")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .frame(minWidth: 500)
    }
}

struct HotkeyRow: View {
    let icon: String
    let name: String
    let shortcut: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.body)
                        .fontWeight(.medium)
                    Spacer()
                    Text(shortcut)
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Security Settings

struct SecuritySettingsView: View {
    @State private var enableSecurityFilter: Bool = SettingsManager.shared.enableSecurityFilter
    
    var body: some View {
        Form {
            Section(header: Text("Security Filter").font(.headline)) {
                Toggle("Enable Security Filter", isOn: $enableSecurityFilter)
                    .onChange(of: enableSecurityFilter) { newValue in
                        SettingsManager.shared.enableSecurityFilter = newValue
                    }
                
                Text("Automatically block sensitive data like passwords, credit cards, and API keys")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("Protected Patterns").font(.headline)) {
                VStack(alignment: .leading, spacing: 8) {
                    PatternRow(icon: "key.fill", name: "Passwords", description: "password=, pwd=")
                    PatternRow(icon: "creditcard.fill", name: "Credit Cards", description: "16-digit numbers")
                    PatternRow(icon: "lock.fill", name: "API Keys", description: "api_key=, token=")
                    PatternRow(icon: "key.horizontal.fill", name: "Private Keys", description: "BEGIN PRIVATE KEY")
                    PatternRow(icon: "envelope.fill", name: "Email Addresses", description: "user@example.com")
                    PatternRow(icon: "phone.fill", name: "Phone Numbers", description: "+1 (555) 123-4567")
                }
            }
        }
        .padding()
        .frame(minWidth: 500)
    }
}

struct PatternRow: View {
    let icon: String
    let name: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.body)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Blacklist Settings

struct BlacklistSettingsView: View {
    @State private var enableBlacklist: Bool = SettingsManager.shared.enableBlacklist
    
    var body: some View {
        Form {
            Section(header: Text("Blacklist").font(.headline)) {
                Toggle("Enable Blacklist", isOn: $enableBlacklist)
                    .onChange(of: enableBlacklist) { newValue in
                        SettingsManager.shared.enableBlacklist = newValue
                    }
                
                Text("Block specific patterns from being saved to clipboard history")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("Preset Rules").font(.headline)) {
                VStack(alignment: .leading, spacing: 8) {
                    BlacklistRuleRow(
                        name: "Development",
                        pattern: "node_modules, .git, build/",
                        description: "Common development files and folders"
                    )
                    
                    Divider()
                    
                    BlacklistRuleRow(
                        name: "Privacy",
                        pattern: "password, secret, token",
                        description: "Sensitive information keywords"
                    )
                    
                    Divider()
                    
                    BlacklistRuleRow(
                        name: "Temporary Files",
                        pattern: ".tmp, .cache, .log",
                        description: "Temporary and cache files"
                    )
                }
            }
            
            Section(header: Text("Custom Rules").font(.headline)) {
                Text("Add your own patterns to block specific content")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button(action: {}) {
                    Label("Add Custom Rule", systemImage: "plus.circle")
                }
                .disabled(true)
                
                Text("Note: Custom rule management will be available in a future update")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .frame(minWidth: 500)
    }
}

struct BlacklistRuleRow: View {
    let name: String
    let pattern: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.body)
                    .fontWeight(.medium)
                Text(pattern)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Auto-Clear Settings

struct AutoClearSettingsView: View {
    @State private var enableAutoClear: Bool = SettingsManager.shared.enableAutoClear
    
    var body: some View {
        Form {
            Section(header: Text("Auto-Clear").font(.headline)) {
                Toggle("Enable Auto-Clear", isOn: $enableAutoClear)
                    .onChange(of: enableAutoClear) { newValue in
                        SettingsManager.shared.enableAutoClear = newValue
                    }
                
                Text("Automatically clear clipboard history after a specified time")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("Presets").font(.headline)) {
                VStack(alignment: .leading, spacing: 8) {
                    PresetRow(name: "Quick Work", interval: "5 minutes", description: "For short work sessions")
                    PresetRow(name: "Confidential", interval: "15 minutes", description: "For sensitive data")
                    PresetRow(name: "Long Session", interval: "1 hour", description: "For extended work")
                    PresetRow(name: "Disabled", interval: "Never", description: "Keep history indefinitely")
                }
            }
            
            Section(header: Text("Options").font(.headline)) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.accentColor)
                        Text("Show notification before clearing")
                    }
                    
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.accentColor)
                        Text("Reset timer on user activity")
                    }
                }
            }
        }
        .padding()
        .frame(minWidth: 500)
    }
}

struct PresetRow: View {
    let name: String
    let interval: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.fill")
                .foregroundColor(.accentColor)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(name)
                        .font(.body)
                    Spacer()
                    Text(interval)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - About

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            
            Text("ClipStack")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Version 1.0.0")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Smart clipboard manager for macOS")
                .font(.body)
            
            Spacer()
            
            Link("GitHub Repository", destination: URL(string: "https://github.com/AlexeyGvozdev/clipstack")!)
                .font(.footnote)
        }
        .padding()
    }
}

// MARK: - Settings Card

struct SettingsCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.accentColor)
                    .frame(width: 32, height: 32)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(8)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(20)
            .padding(.bottom, 16)
            
            // Content
            content
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// Preview is available only in Xcode
// To preview: Open in Xcode and use Canvas