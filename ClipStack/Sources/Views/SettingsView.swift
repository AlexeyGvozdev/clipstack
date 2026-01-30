//
//  SettingsView.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 30.01.2026.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            HotkeysSettingsView()
                .tabItem {
                    Label("Hotkeys", systemImage: "keyboard")
                }
            
            SecuritySettingsView()
                .tabItem {
                    Label("Security", systemImage: "lock.shield")
                }
            
            BlacklistSettingsView()
                .tabItem {
                    Label("Blacklist", systemImage: "xmark.circle")
                }
            
            AutoClearSettingsView()
                .tabItem {
                    Label("Auto-Clear", systemImage: "clock")
                }
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 600, height: 400)
    }
}

// MARK: - General Settings

struct GeneralSettingsView: View {
    var body: some View {
        Form {
            Text("General Settings")
                .font(.headline)
            // TODO: Implement general settings
        }
        .padding()
    }
}

// MARK: - Hotkeys Settings

struct HotkeysSettingsView: View {
    var body: some View {
        Form {
            Text("Hotkeys Settings")
                .font(.headline)
            // TODO: Implement hotkeys settings
        }
        .padding()
    }
}

// MARK: - Security Settings

struct SecuritySettingsView: View {
    var body: some View {
        Form {
            Text("Security Settings")
                .font(.headline)
            // TODO: Implement security settings
        }
        .padding()
    }
}

// MARK: - Blacklist Settings

struct BlacklistSettingsView: View {
    var body: some View {
        Form {
            Text("Blacklist Settings")
                .font(.headline)
            // TODO: Implement blacklist settings
        }
        .padding()
    }
}

// MARK: - Auto-Clear Settings

struct AutoClearSettingsView: View {
    var body: some View {
        Form {
            Text("Auto-Clear Settings")
                .font(.headline)
            // TODO: Implement auto-clear settings
        }
        .padding()
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

// Preview is available only in Xcode
// To preview: Open in Xcode and use Canvas