# Система горячих клавиш ClipStack

## Обзор

ClipStack использует глобальные горячие клавиши для быстрого доступа к функциям буфера обмена без необходимости переключения на приложение.

## Архитектура

### Компоненты

1. **HotkeyManager** - основной класс для управления горячими клавишами
   - Использует Carbon Events API для регистрации глобальных горячих клавиш
   - Реализует паттерн делегата для уведомления о нажатиях
   - Поддерживает регистрацию/отмену регистрации горячих клавиш

2. **HotkeyManagerDelegate** - протокол для обработки событий горячих клавиш
   - Метод `hotkeyPressed(_:)` вызывается при нажатии зарегистрированной клавиши

3. **HotkeyIdentifier** - enum с идентификаторами горячих клавиш
   - Содержит метаданные: displayName, shortcut, description

## Горячие клавиши по умолчанию

| Комбинация | Действие | Описание |
|------------|----------|----------|
| `⌘⇧V` | Pop First | Извлечь и вставить первый элемент из буфера |
| `⌘⇧B` | Pop Last | Извлечь и вставить последний элемент из буфера |
| `⌘⇧M` | Toggle Mode | Переключить режим Stack ↔ Queue |
| `⌘⇧C` | Show Buffer | Открыть окно предпросмотра буфера |
| `⌘⇧X` | Clear Buffer | Очистить весь буфер |

## Использование

### Инициализация

```swift
let hotkeyManager = HotkeyManager()
hotkeyManager.delegate = self
hotkeyManager.registerDefaultHotkeys()
```

### Реализация делегата

```swift
extension AppDelegate: HotkeyManagerDelegate {
    func hotkeyPressed(_ identifier: HotkeyManager.HotkeyIdentifier) {
        switch identifier {
        case .popFirst:
            handlePopFirst()
        case .popLast:
            handlePopLast()
        case .toggleMode:
            handleToggleMode()
        case .showBuffer:
            handleShowBuffer()
        case .clearBuffer:
            handleClearBuffer()
        }
    }
}
```

### Отмена регистрации

```swift
hotkeyManager.unregisterAllHotkeys()
```

## Технические детали

### Carbon Events API

Система использует Carbon Events API для регистрации глобальных горячих клавиш:

```swift
RegisterEventHotKey(
    keyCode,           // Код клавиши (например, 0x09 для 'V')
    modifierFlags,     // Модификаторы (Cmd, Shift, etc.)
    hotkeyID,          // Уникальный идентификатор
    GetApplicationEventTarget(),
    0,
    &hotKeyRef
)
```

### Коды клавиш

| Клавиша | Код |
|---------|-----|
| V | 0x09 |
| B | 0x0B |
| M | 0x2E |
| C | 0x08 |
| X | 0x07 |

### Модификаторы

- `cmdKey` (⌘) - Command
- `shiftKey` (⇧) - Shift
- `optionKey` (⌥) - Option/Alt
- `controlKey` (⌃) - Control

## Обработка событий

1. Пользователь нажимает горячую клавишу
2. Carbon Events API перехватывает событие
3. Вызывается callback-функция
4. Определяется идентификатор горячей клавиши
5. Вызывается метод делегата `hotkeyPressed(_:)`
6. AppDelegate обрабатывает действие

## Интеграция с ClipBuffer

### Pop First (⌘⇧V)

```swift
private func handlePopFirst() {
    guard let item = clipBuffer.pop() else { return }
    
    // Остановить мониторинг
    clipboardMonitor.stopMonitoring()
    
    // Вставить содержимое
    clipboardMonitor.paste(item.content)
    
    // Возобновить мониторинг через 0.5 сек
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.clipboardMonitor.startMonitoring()
    }
    
    updateMenuBarBadge()
}
```

### Pop Last (⌘⇧B)

Аналогично Pop First, но использует `clipBuffer.popLast()` для извлечения последнего элемента.

### Toggle Mode (⌘⇧M)

```swift
private func handleToggleMode() {
    clipBuffer.toggleMode()
    
    // Показать уведомление
    let notification = NSUserNotification()
    notification.title = "ClipStack Mode Changed"
    notification.informativeText = "Switched to \(clipBuffer.mode.displayName) mode"
    NSUserNotificationCenter.default.deliver(notification)
}
```

### Show Buffer (⌘⇧C)

```swift
private func handleShowBuffer() {
    // TODO: Реализовать в Stage 10
    // Открыть окно предпросмотра буфера
}
```

### Clear Buffer (⌘⇧X)

```swift
private func handleClearBuffer() {
    let count = clipBuffer.count
    clipBuffer.clear()
    updateMenuBarBadge()
    
    // Показать уведомление
    let notification = NSUserNotification()
    notification.title = "ClipStack Buffer Cleared"
    notification.informativeText = "Removed \(count) item(s)"
    NSUserNotificationCenter.default.deliver(notification)
}
```

## Требования к системе

### Разрешения

Для работы глобальных горячих клавиш требуется:

1. **Accessibility permissions** - для перехвата клавиатурных событий
2. Добавить в `Info.plist`:
   ```xml
   <key>NSAppleEventsUsageDescription</key>
   <string>ClipStack needs accessibility access to register global hotkeys</string>
   ```

### Проверка разрешений

```swift
let options: NSDictionary = [
    kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
]
let accessEnabled = AXIsProcessTrustedWithOptions(options)
```

## Тестирование

### Unit Tests

```swift
func testRegisterDefaultHotkeys() {
    hotkeyManager.registerDefaultHotkeys()
    // Проверка успешной регистрации
}

func testHotkeyIdentifierProperties() {
    XCTAssertEqual(HotkeyIdentifier.popFirst.shortcut, "⌘⇧V")
    XCTAssertEqual(HotkeyIdentifier.popFirst.displayName, "Extract First")
}
```

### Ручное тестирование

1. Запустить приложение
2. Предоставить Accessibility permissions
3. Скопировать несколько элементов в буфер
4. Нажать `⌘⇧V` - должен вставиться первый элемент
5. Нажать `⌘⇧M` - должно появиться уведомление о смене режима
6. Нажать `⌘⇧X` - буфер должен очиститься

## Известные ограничения

1. **Конфликты с системными горячими клавишами** - некоторые комбинации могут быть заняты системой или другими приложениями
2. **Accessibility permissions** - требуется явное разрешение пользователя
3. **Задержка после вставки** - необходима пауза 0.5 сек перед возобновлением мониторинга, чтобы избежать повторного захвата вставленного содержимого

## Будущие улучшения

1. **Настраиваемые горячие клавиши** - позволить пользователю изменять комбинации клавиш
2. **Визуальная обратная связь** - показывать HUD при нажатии горячих клавиш
3. **Конфликт-менеджер** - предупреждать о конфликтах с другими приложениями
4. **Профили горячих клавиш** - разные наборы для разных сценариев использования

## Ссылки

- [Carbon Event Manager Reference](https://developer.apple.com/documentation/carbon/carbon_event_manager)
- [Accessibility Programming Guide](https://developer.apple.com/library/archive/documentation/Accessibility/Conceptual/AccessibilityMacOSX/)
- [CGEvent Reference](https://developer.apple.com/documentation/coregraphics/cgevent)