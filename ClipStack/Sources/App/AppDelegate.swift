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
    // MARK: - Properties
    
    private lazy var appCoordinator = AppCoordinator()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize the app coordinator
        appCoordinator.initialize()
    }
}