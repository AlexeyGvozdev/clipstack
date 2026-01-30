# ClipStack Tests

## Running Tests

### Using Xcode
1. Open `ClipStack.xcodeproj` in Xcode
2. Press `Cmd+U` to run all tests
3. View test results in the Test Navigator

### Using Command Line
```bash
# Run all tests
make test

# Or directly with xcodebuild
xcodebuild test -scheme ClipStack -destination 'platform=macOS'
```

## Test Structure

```
Tests/
├── UnitTests/
│   ├── ClipBufferTests.swift      # Core buffer functionality tests
│   └── HotkeyManagerTests.swift   # Hotkey system tests
└── IntegrationTests/               # Integration tests (coming soon)
```

## Test Coverage

### Core Module
- ✅ ClipBuffer initialization
- ✅ Push operations
- ✅ Stack mode (LIFO) operations
- ✅ Queue mode (FIFO) operations
- ✅ Mode toggling
- ✅ Clear and remove operations
- ✅ Search functionality
- ✅ Old items removal

### Hotkey Module
- ✅ HotkeyManager initialization
- ✅ Hotkey registration and unregistration
- ✅ Hotkey identifier properties (display names, shortcuts, descriptions)
- ✅ Delegate pattern (weak reference)

## Writing Tests

Follow these guidelines when writing tests:

1. **Naming**: Use descriptive test names that explain what is being tested
   ```swift
   func testStackModePop() { ... }
   ```

2. **Structure**: Follow Arrange-Act-Assert pattern
   ```swift
   // Arrange
   buffer.push(createTestItem("A"))
   
   // Act
   let result = buffer.pop()
   
   // Assert
   XCTAssertEqual(result?.content, "A")
   ```

3. **Isolation**: Each test should be independent
   - Use `setUp()` to create fresh instances
   - Use `tearDown()` to clean up

4. **Coverage**: Aim for >75% code coverage

## Note

Tests require Xcode to run due to XCTest framework limitations with Swift Package Manager executable targets. The test files are included in the repository for documentation and will be properly integrated when creating the Xcode project.