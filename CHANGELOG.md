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
- SettingsManager for application settings persistence
- Settings for buffer mode, notifications, security, auto-clear
- App settings (launch at login, show in dock, theme)
- Settings export/import functionality
- AppTheme enum (system, light, dark)
- Unit tests for CoreDataManager (20+ test cases)
- Unit tests for SettingsManager (25+ test cases)
- Documentation: Storage Module test coverage in Tests/README.md

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