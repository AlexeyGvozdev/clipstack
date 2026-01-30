//
//  HotkeyManager.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 30.01.2026.
//

import Carbon
import AppKit

/// Manages global hotkeys using Carbon Events API
final class HotkeyManager {
    // MARK: - Types
    
    enum HotkeyIdentifier: UInt32 {
        case popFirst = 1       // Cmd+Shift+V - Extract first item
        case popLast = 2        // Cmd+Shift+B - Extract last item
        case toggleMode = 3     // Cmd+Shift+M - Toggle Stack/Queue mode
        case showBuffer = 4     // Cmd+Shift+C - Show buffer preview
        case clearBuffer = 5    // Cmd+Shift+X - Clear buffer
    }
    
    // MARK: - Properties
    
    private var hotkeys: [HotkeyIdentifier: EventHotKeyRef?] = [:]
    private var eventHandler: EventHandlerRef?
    
    weak var delegate: HotkeyManagerDelegate?
    
    // MARK: - Initialization
    
    init() {
        setupEventHandler()
    }
    
    deinit {
        unregisterAllHotkeys()
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }
    
    // MARK: - Public Methods
    
    /// Register all default hotkeys
    func registerDefaultHotkeys() {
        // Cmd+Shift+V - Pop first
        registerHotkey(.popFirst, keyCode: 0x09, modifiers: [.maskCommand, .maskShift])
        
        // Cmd+Shift+B - Pop last
        registerHotkey(.popLast, keyCode: 0x0B, modifiers: [.maskCommand, .maskShift])
        
        // Cmd+Shift+M - Toggle mode
        registerHotkey(.toggleMode, keyCode: 0x2E, modifiers: [.maskCommand, .maskShift])
        
        // Cmd+Shift+C - Show buffer
        registerHotkey(.showBuffer, keyCode: 0x08, modifiers: [.maskCommand, .maskShift])
        
        // Cmd+Shift+X - Clear buffer
        registerHotkey(.clearBuffer, keyCode: 0x07, modifiers: [.maskCommand, .maskShift])
    }
    
    /// Unregister all hotkeys
    func unregisterAllHotkeys() {
        for (_, hotkeyRef) in hotkeys {
            if let ref = hotkeyRef {
                UnregisterEventHotKey(ref)
            }
        }
        hotkeys.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func setupEventHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        
        let callback: EventHandlerUPP = { _, event, userData in
            guard let userData = userData else { return OSStatus(eventNotHandledErr) }
            
            let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
            
            var hotkeyID = EventHotKeyID()
            let status = GetEventParameter(
                event,
                UInt32(kEventParamDirectObject),
                UInt32(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotkeyID
            )
            
            guard status == noErr,
                  let identifier = HotkeyIdentifier(rawValue: hotkeyID.id) else {
                return OSStatus(eventNotHandledErr)
            }
            
            DispatchQueue.main.async {
                manager.delegate?.hotkeyPressed(identifier)
            }
            
            return noErr
        }
        
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            callback,
            1,
            &eventType,
            selfPtr,
            &eventHandler
        )
    }
    
    private func registerHotkey(
        _ identifier: HotkeyIdentifier,
        keyCode: UInt32,
        modifiers: [CGEventFlags]
    ) {
        var hotKeyRef: EventHotKeyRef?
        
        let modifierFlags = modifiers.reduce(UInt32(0)) { result, flag in
            switch flag {
            case .maskCommand:
                return result | UInt32(cmdKey)
            case .maskShift:
                return result | UInt32(shiftKey)
            case .maskAlternate:
                return result | UInt32(optionKey)
            case .maskControl:
                return result | UInt32(controlKey)
            default:
                return result
            }
        }
        
        let hotkeyID = EventHotKeyID(
            signature: OSType(0x4353), // 'CS' for ClipStack
            id: identifier.rawValue
        )
        
        let status = RegisterEventHotKey(
            keyCode,
            modifierFlags,
            hotkeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if status == noErr {
            hotkeys[identifier] = hotKeyRef
        } else {
            print("Failed to register hotkey \(identifier): \(status)")
        }
    }
}

// MARK: - HotkeyManagerDelegate

protocol HotkeyManagerDelegate: AnyObject {
    /// Called when a registered hotkey is pressed
    /// - Parameter identifier: The identifier of the pressed hotkey
    func hotkeyPressed(_ identifier: HotkeyManager.HotkeyIdentifier)
}

// MARK: - Hotkey Display Names

extension HotkeyManager.HotkeyIdentifier {
    var displayName: String {
        switch self {
        case .popFirst:
            return "Extract First"
        case .popLast:
            return "Extract Last"
        case .toggleMode:
            return "Toggle Mode"
        case .showBuffer:
            return "Show Buffer"
        case .clearBuffer:
            return "Clear Buffer"
        }
    }
    
    var shortcut: String {
        switch self {
        case .popFirst:
            return "⌘⇧V"
        case .popLast:
            return "⌘⇧B"
        case .toggleMode:
            return "⌘⇧M"
        case .showBuffer:
            return "⌘⇧C"
        case .clearBuffer:
            return "⌘⇧X"
        }
    }
    
    var description: String {
        switch self {
        case .popFirst:
            return "Extract and paste the first item from buffer"
        case .popLast:
            return "Extract and paste the last item from buffer"
        case .toggleMode:
            return "Switch between Stack and Queue modes"
        case .showBuffer:
            return "Open buffer preview window"
        case .clearBuffer:
            return "Remove all items from buffer"
        }
    }
}