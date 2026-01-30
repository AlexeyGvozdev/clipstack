//
//  ClipStackApp.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 30.01.2026.
//

import SwiftUI

@main
struct ClipStackApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}