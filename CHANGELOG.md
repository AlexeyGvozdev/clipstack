# Changelog

All notable changes to ClipStack will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project setup
- Project structure and folder organization
- Basic SwiftUI app with menu bar support
- Settings window with tabs (General, Hotkeys, Security, Blacklist, Auto-Clear, About)
- SwiftLint configuration
- Makefile for common tasks
- Package.swift for Swift Package Manager
- GitHub templates (PR, Bug Report, Feature Request)
- Git Flow workflow with develop branch
- Core buffer functionality with Stack (LIFO) and Queue (FIFO) modes
- ClipItem model with content type detection (plainText, url, code, email)
- ClipBuffer with full buffer operations (push, pop, peek, clear, search)
- Clipboard monitoring with NSPasteboard API
- Automatic content type detection and source app tracking
- Global hotkey system using Carbon Events API
- 5 default hotkeys: Pop First (⌘⇧V), Pop Last (⌘⇧B), Toggle Mode (⌘⇧M), Show Buffer (⌘⇧C), Clear Buffer (⌘⇧X)
- Menu bar badge showing item count
- Unit tests for ClipBuffer (20+ test cases)
- Unit tests for HotkeyManager
- Documentation: HOTKEYS.md
- GitHub Actions CI/CD workflow
- Automated build verification on push and PR
- SwiftLint checks in CI
- Code quality checks (file headers, line count, TODO comments)
- CI status badge in README
- SecurityFilter class with 8 sensitive data patterns (passwords, credit cards, API keys, private keys, JWT tokens, emails, phone numbers, SSN)
- Automatic blocking of sensitive clipboard content
- User notifications when sensitive data is detected and blocked
- ClipboardSecurityDelegate protocol for security event handling
- Unit tests for SecurityFilter (25+ test cases)
- Documentation: Security Module test coverage in Tests/README.md
- BlacklistRule model with pattern matching support
- BlacklistManager with rule management (add, remove, update, toggle)
- BlacklistStorage protocol with UserDefaults implementation
- Case-sensitive and case-insensitive pattern matching
- Preset rules: Development, Privacy, Temporary Files
- Import/Export functionality for blacklist rules (JSON format)
- Integration with ClipboardMonitor for automatic content blocking
- ClipboardBlacklistDelegate protocol for blacklist event handling
- User notifications when content is blocked by blacklist
- Unit tests for BlacklistManager (25+ test cases)
- Documentation: Blacklist Module test coverage in Tests/README.md
- AutoClearSettings model with configurable intervals and presets
- AutoClearManager class with timer-based automatic buffer clearing
- 7 preset time intervals: 5min, 15min, 30min, 1hour, 2hours, 4hours, never
- Preset configurations: quickWork, confidential, longSession, disabled
- Countdown timer with real-time UI updates
- Notification support (before clear and after clear)
- Activity handling (reset timer on user activity)
- Postpone functionality for delaying scheduled clears
- Integration with ClipBuffer via AutoClearManagerDelegate protocol
- Settings persistence via UserDefaults
- Unit tests for AutoClearManager (10+ test cases)
- Documentation: AutoClear Module test coverage in Tests/README.md
- Core Data model (ClipStack.xcdatamodeld) with ClipItemEntity
- ClipItemEntity NSManagedObject with conversion methods
- CoreDataManager singleton for persistent storage
- Save/load operations for ClipItems (single and batch)
- Advanced fetch requests (by type, source app, date range)
- Delete operations (single, multiple, all, old items)
- Statistics methods (item count, storage size estimate)
- Maintenance operations (cleanup old items, reset database)
- Auto-save functionality with configurable interval
- Preview window with SwiftUI interface
- Settings window with 6 tabs (General, Hotkeys, Security, Blacklist, Auto-Clear, About)
- Menu bar application with LSUIElement support
- SettingsManager for centralized settings management
- Complete UI integration with AppKit + SwiftUI

### Added
- **Module Integration**: Complete integration of all modules through AppCoordinator
- **Core Data Integration**: Automatic saving and loading of clipboard items in ClipBuffer
- **Settings Integration**: Centralized settings management across all modules
- **AppCoordinator**: Central coordinator for managing all app modules and interactions
- **Enhanced UI/UX**: Modern design system with improved visual hierarchy
- **New Content Types**: Image, File, Color, Phone Number support with automatic detection
- **Modern Components**: Enhanced buttons, cards, and interactive elements
- **Advanced Animations**: Smooth transitions and micro-interactions throughout the app
- **Improved Color Scheme**: Type-specific colors for better content recognition
- **Enhanced Search Interface**: Real-time filtering with improved visual feedback
- **Modern Settings Design**: Sidebar navigation with card-based layout
- **Better Visual Feedback**: Enhanced hover effects and action confirmations
- **Accessibility Improvements**: Better contrast and navigation support

### Changed
- **Complete UI Redesign**: Modern, clean interface with consistent styling
- **Enhanced ClipItemRowView**: Improved layout with better visual hierarchy and interactions
- **Redesigned PreviewView**: Better organization and enhanced search capabilities
- **Modern SettingsView**: Sidebar navigation with improved user experience
- **Improved Typography**: Better font sizing and spacing throughout the application
- **Enhanced Color Coding**: Consistent color scheme for different content types
- **Better Animations**: Smoother transitions and more responsive interactions
- **Improved Button Styling**: Modern button designs with better visual feedback
- **Enhanced Search Experience**: Real-time filtering with improved UI
- **Better Settings Organization**: More intuitive layout and navigation

### Fixed
- **UI Layout Issues**: Fixed layout problems on different screen sizes
- **Color Contrast**: Improved contrast for better readability
- **Animation Performance**: Optimized animations for smoother performance
- **Button State Management**: Fixed button interaction states
- **Visual Feedback**: Improved feedback for user actions
- **Auto-save functionality**: Timer-based automatic saving to Core Data from ClipBuffer
- **Settings synchronization**: Real-time settings application across all modules
- **Simplified AppDelegate**: AppDelegate now uses AppCoordinator for all module management
- **Module documentation**: Complete documentation of module integration in docs/MODULE_INTEGRATION.md

### Changed
- **ClipBuffer**: Now integrates with CoreDataManager and SettingsManager for persistence
- **ClipboardMonitor**: Now respects security and blacklist settings from SettingsManager
- **AutoClearManager**: Now synchronizes with SettingsManager for enable/disable state
- **AppDelegate**: Simplified to delegate all functionality to AppCoordinator
- SettingsManager for application settings persistence
- Settings for buffer mode, notifications, security, auto-clear
- App settings (launch at login, show in dock, theme)
- Settings export/import functionality
- AppTheme enum (system, light, dark)
- Unit tests for CoreDataManager (20+ test cases)
- Unit tests for SettingsManager (25+ test cases)
- Documentation: Storage Module test coverage in Tests/README.md
- AppDelegate with menu bar integration (NSStatusItem)
- Menu bar icon with badge counter showing buffer item count
- Context menu with all main actions and hotkey shortcuts
- Integration with all modules (ClipBuffer, ClipboardMonitor, HotkeyManager, SecurityFilter, BlacklistManager, AutoClearManager)
- Delegate implementations for clipboard, hotkeys, security, and blacklist events
- UserNotifications support for clipboard events
- Info.plist with proper bundle configuration (LSUIElement, usage descriptions)
- Entitlements file with required permissions (Apple Events, File Access)
- Build script (create-app-bundle.sh) for creating proper macOS App Bundle
- Documentation: MENU_BAR.md with complete menu bar app guide
- PreviewWindowController for managing preview window
- PreviewView SwiftUI component with search and filter functionality
- ClipItemRowView component for displaying individual clipboard items
- Search functionality for filtering items by content
- Content type filter (Text, URL, Code, Email)
- Item actions: copy to clipboard, delete item
- Clear all functionality with confirmation
- Hover effects and animations for better UX
- Empty state view when no items or no search results
- Integration with AppDelegate for hotkey support (⌘⇧C)
- Documentation: PREVIEW_WINDOW.md with complete preview window guide
- SettingsWindowController for managing settings window
- SettingsView SwiftUI component with 6 tabs (General, Hotkeys, Security, Blacklist, Auto-Clear, About)
- General settings: buffer mode, max buffer size, notifications, launch at login
- Hotkeys display: all 5 hotkeys with icons, shortcuts, and descriptions
- Security settings: security filter toggle and protected patterns display
- Blacklist settings: blacklist toggle and preset rules display
- Auto-clear settings: auto-clear toggle, presets, and options
- About section: app information and GitHub link
- Reusable components: HotkeyRow, PatternRow, PresetRow, BlacklistRuleRow
- Real-time settings synchronization with SettingsManager
- Integration with AppDelegate for menu bar access (⌘,)
- Documentation: SETTINGS_WINDOW.md with complete settings window guide

### Changed
- Moved all documentation to `docs/` folder
- Migrated from NSUserNotification to UserNotifications framework

### Fixed

### Removed

## [1.0.0] - TBD

### Added
- Stack (LIFO) and Queue (FIFO) modes
- Clipboard monitoring
- Hotkey system
- Security filter for sensitive data
- Blacklist manager
- Auto-clear functionality
- Menu bar interface
- Preview window
- Core Data persistence

[Unreleased]: https://github.com/AlexeyGvozdev/clipstack/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/AlexeyGvozdev/clipstack/releases/tag/v1.0.0