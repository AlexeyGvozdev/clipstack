# Menu Bar App

## Обзор

Menu Bar приложение ClipStack - это основной интерфейс пользователя, который отображается в строке меню macOS. Приложение работает в фоновом режиме без иконки в Dock.

## Архитектура

### Компоненты

1. **AppDelegate** - главный контроллер приложения
2. **NSStatusItem** - иконка и меню в menu bar
3. **App Bundle** - правильная структура macOS приложения

### Структура App Bundle

```
ClipStack.app/
├── Contents/
│   ├── Info.plist          # Метаданные приложения
│   ├── MacOS/
│   │   └── ClipStack       # Исполняемый файл
│   ├── Resources/
│   │   └── ClipStack.entitlements  # Разрешения
│   └── PkgInfo             # Тип приложения
```

## Функциональность

### Menu Bar Icon

- **Иконка**: 📋 (clipboard emoji)
- **Badge**: Показывает количество элементов в буфере
- **Клик**: Открывает контекстное меню

### Контекстное меню

```
┌─────────────────────────────┐
│ ClipStack (0)               │
├─────────────────────────────┤
│ Show History    ⌘⇧V         │
│ Show Blacklist  ⌘⇧B         │
│ Toggle Mode     ⌘⇧M         │
│ Clear Buffer    ⌘⇧C         │
├─────────────────────────────┤
│ Settings...                 │
│ Quit            ⌘Q          │
└─────────────────────────────┘
```

### Горячие клавиши

Все горячие клавиши работают глобально:

- **⌘⇧V** - Показать историю буфера
- **⌘⇧B** - Показать чёрный список
- **⌘⇧M** - Переключить режим (Stack/Queue)
- **⌘⇧C** - Очистить буфер
- **⌘⇧X** - Экстренная очистка (удаляет всё)

## Интеграция модулей

### ClipboardMonitor

```swift
func clipboardMonitor(_ monitor: ClipboardMonitor, didAddItem item: ClipboardItem) {
    updateBadge()
    showNotification(title: "Item Added", body: item.preview)
}
```

### HotkeyManager

```swift
func hotkeyManager(_ manager: HotkeyManager, didTrigger action: HotkeyAction) {
    switch action {
    case .showHistory:
        // Показать окно истории
    case .showBlacklist:
        // Показать окно чёрного списка
    // ...
    }
}
```

### SecurityFilter

```swift
func clipboardSecurity(_ security: ClipboardSecurity, 
                       didBlockItem item: ClipboardItem, 
                       reason: String) {
    showNotification(
        title: "Security Alert",
        body: "Blocked: \(reason)"
    )
}
```

### BlacklistManager

```swift
func clipboardBlacklist(_ blacklist: ClipboardBlacklist,
                        didBlockItem item: ClipboardItem,
                        byRule rule: BlacklistRule) {
    showNotification(
        title: "Blacklist Alert",
        body: "Blocked by rule: \(rule.name)"
    )
}
```

## Уведомления

Приложение использует `UserNotifications` framework для показа уведомлений:

- **Добавление элемента** - при копировании нового элемента
- **Блокировка Security** - при блокировке чувствительных данных
- **Блокировка Blacklist** - при срабатывании правила чёрного списка
- **Очистка буфера** - при автоматической или ручной очистке

## Разрешения

### Info.plist

```xml
<key>LSUIElement</key>
<true/>  <!-- Скрыть из Dock -->

<key>NSAppleEventsUsageDescription</key>
<string>ClipStack needs Apple Events access for hotkeys</string>

<key>NSSystemAdministrationUsageDescription</key>
<string>ClipStack needs system administration access</string>

<key>NSUserNotificationUsageDescription</key>
<string>ClipStack shows notifications for clipboard events</string>
```

### Entitlements

```xml
<key>com.apple.security.app-sandbox</key>
<false/>  <!-- Отключен для доступа к буферу обмена -->

<key>com.apple.security.automation.apple-events</key>
<true/>  <!-- Для горячих клавиш -->

<key>com.apple.security.files.user-selected.read-write</key>
<true/>  <!-- Для работы с файлами -->
```

## Сборка

### Использование скрипта

```bash
# Сделать скрипт исполняемым
chmod +x scripts/create-app-bundle.sh

# Собрать App Bundle
./scripts/create-app-bundle.sh

# Запустить приложение
open .build/release/ClipStack.app

# Или с выводом в консоль
.build/release/ClipStack.app/Contents/MacOS/ClipStack
```

### Ручная сборка

```bash
# 1. Собрать release версию
swift build -c release

# 2. Создать структуру App Bundle
mkdir -p .build/release/ClipStack.app/Contents/MacOS
mkdir -p .build/release/ClipStack.app/Contents/Resources

# 3. Скопировать файлы
cp .build/release/ClipStack .build/release/ClipStack.app/Contents/MacOS/
cp ClipStack/Resources/Info.plist .build/release/ClipStack.app/Contents/
cp ClipStack/Resources/ClipStack.entitlements .build/release/ClipStack.app/Contents/Resources/

# 4. Создать PkgInfo
echo "APPL????" > .build/release/ClipStack.app/Contents/PkgInfo
```

## Системные требования

- **macOS**: 12.0 (Monterey) или новее
- **Разрешения**: 
  - Accessibility (для горячих клавиш)
  - Automation (для Apple Events)
  - Notifications (для уведомлений)

## Настройка разрешений

После первого запуска необходимо предоставить разрешения:

1. **System Settings** → **Privacy & Security** → **Accessibility**
   - Добавить ClipStack в список разрешённых приложений

2. **System Settings** → **Privacy & Security** → **Automation**
   - Разрешить ClipStack управлять другими приложениями

3. **System Settings** → **Notifications**
   - Настроить стиль уведомлений для ClipStack

## Отладка

### Просмотр логов

```bash
# Запустить с выводом в консоль
.build/release/ClipStack.app/Contents/MacOS/ClipStack

# Или использовать Console.app
# Фильтр: process:ClipStack
```

### Проверка процесса

```bash
# Проверить, что приложение запущено
ps aux | grep ClipStack | grep -v grep

# Убить процесс
killall ClipStack
```

### Проверка разрешений

```bash
# Проверить статус Accessibility
tccutil reset Accessibility com.alexeygvozdev.clipstack

# Проверить статус Automation
tccutil reset AppleEvents com.alexeygvozdev.clipstack
```

## Известные проблемы

### UserNotifications требует App Bundle

**Проблема**: При запуске через `swift run` приложение падает с ошибкой:
```
NSInternalInconsistencyException: 
bundleProxyForCurrentProcess is nil: 
UNUserNotificationCenter is not available
```

**Решение**: Использовать правильный App Bundle вместо CLI executable.

### Горячие клавиши не работают

**Проблема**: Горячие клавиши не срабатывают.

**Решение**: 
1. Проверить разрешения Accessibility
2. Перезапустить приложение
3. Проверить, что другие приложения не используют те же комбинации

### Иконка не появляется в menu bar

**Проблема**: Иконка не отображается в строке меню.

**Решение**:
1. Проверить, что `LSUIElement` установлен в `true`
2. Проверить, что `NSStatusItem` создан правильно
3. Перезапустить приложение

## Следующие шаги

1. **Preview Window** - окно предпросмотра истории
2. **Settings Window** - окно настроек приложения
3. **Улучшение UI** - иконки, анимации, темы
4. **Локализация** - поддержка нескольких языков

## Ссылки

- [NSStatusItem Documentation](https://developer.apple.com/documentation/appkit/nsstatusitem)
- [UserNotifications Framework](https://developer.apple.com/documentation/usernotifications)
- [App Bundle Structure](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html)
- [Entitlements](https://developer.apple.com/documentation/bundleresources/entitlements)