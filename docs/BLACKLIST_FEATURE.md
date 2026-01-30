# Функционал чёрного списка (Blacklist)

## 🎯 Назначение

Чёрный список позволяет пользователю настроить фильтрацию копируемых значений по подстрокам. Если скопированный текст содержит любую из подстрок из чёрного списка, он **не будет добавлен** в буфер ClipStack.

## 💡 Примеры использования

### Пример 1: Фильтрация внутренних URL
```
Чёрный список: ["localhost", "127.0.0.1", "internal.company.com"]

Копируете: "http://localhost:3000/api/users"
Результат: ❌ Игнорируется (содержит "localhost")

Копируете: "https://example.com/api/users"
Результат: ✅ Добавляется в буфер
```

### Пример 2: Фильтрация временных данных
```
Чёрный список: ["tmp", "temp", "draft"]

Копируете: "tmp_file_12345.txt"
Результат: ❌ Игнорируется (содержит "tmp")

Копируете: "final_document.txt"
Результат: ✅ Добавляется в буфер
```

### Пример 3: Фильтрация конфиденциальной информации
```
Чёрный список: ["CONFIDENTIAL", "SECRET", "INTERNAL"]

Копируете: "CONFIDENTIAL: Project Alpha"
Результат: ❌ Игнорируется (содержит "CONFIDENTIAL")

Копируете: "Public announcement"
Результат: ✅ Добавляется в буфер
```

## 🏗️ Техническая реализация

### Модель данных

```swift
struct BlacklistRule: Identifiable, Codable, Equatable {
    let id: UUID
    var pattern: String
    var isEnabled: Bool
    var isCaseSensitive: Bool
    var description: String?
    let createdAt: Date
    
    init(
        pattern: String,
        isEnabled: Bool = true,
        isCaseSensitive: Bool = false,
        description: String? = nil
    ) {
        self.id = UUID()
        self.pattern = pattern
        self.isEnabled = isEnabled
        self.isCaseSensitive = isCaseSensitive
        self.description = description
        self.createdAt = Date()
    }
}

class BlacklistManager: ObservableObject {
    @Published private(set) var rules: [BlacklistRule] = []
    
    private let storage: BlacklistStorage
    
    init(storage: BlacklistStorage = UserDefaultsBlacklistStorage()) {
        self.storage = storage
        self.rules = storage.load()
    }
    
    // MARK: - Public API
    
    func addRule(_ rule: BlacklistRule) {
        rules.append(rule)
        save()
    }
    
    func removeRule(id: UUID) {
        rules.removeAll { $0.id == id }
        save()
    }
    
    func updateRule(_ rule: BlacklistRule) {
        if let index = rules.firstIndex(where: { $0.id == rule.id }) {
            rules[index] = rule
            save()
        }
    }
    
    func toggleRule(id: UUID) {
        if let index = rules.firstIndex(where: { $0.id == id }) {
            rules[index].isEnabled.toggle()
            save()
        }
    }
    
    func isBlacklisted(_ content: String) -> (blocked: Bool, matchedRule: BlacklistRule?) {
        for rule in rules where rule.isEnabled {
            let searchContent = rule.isCaseSensitive ? content : content.lowercased()
            let searchPattern = rule.isCaseSensitive ? rule.pattern : rule.pattern.lowercased()
            
            if searchContent.contains(searchPattern) {
                return (true, rule)
            }
        }
        return (false, nil)
    }
    
    // MARK: - Preset Rules
    
    func loadDefaultRules() {
        let defaults: [BlacklistRule] = [
            BlacklistRule(
                pattern: "localhost",
                description: "Локальные URL"
            ),
            BlacklistRule(
                pattern: "127.0.0.1",
                description: "Локальный IP адрес"
            ),
            BlacklistRule(
                pattern: "tmp",
                description: "Временные файлы"
            ),
            BlacklistRule(
                pattern: "CONFIDENTIAL",
                isCaseSensitive: true,
                description: "Конфиденциальная информация"
            )
        ]
        
        rules.append(contentsOf: defaults)
        save()
    }
    
    // MARK: - Private
    
    private func save() {
        storage.save(rules)
    }
}
```

### Интеграция с ClipboardMonitor

```swift
class ClipboardMonitor: ObservableObject {
    // ... существующий код ...
    
    private let blacklistManager: BlacklistManager
    private let securityFilter: SecurityFilter
    
    init(
        blacklistManager: BlacklistManager,
        securityFilter: SecurityFilter
    ) {
        self.blacklistManager = blacklistManager
        self.securityFilter = securityFilter
        // ...
    }
    
    private func checkForChanges() {
        guard pasteboard.changeCount != changeCount else { return }
        changeCount = pasteboard.changeCount
        
        if let string = pasteboard.string(forType: .string) {
            // 1. Проверка на чувствительные данные
            if securityFilter.isSensitive(string) {
                notifyUser("Чувствительные данные не сохранены", type: .security)
                return
            }
            
            // 2. Проверка чёрного списка
            let blacklistCheck = blacklistManager.isBlacklisted(string)
            if blacklistCheck.blocked {
                let ruleName = blacklistCheck.matchedRule?.description ?? "правило"
                notifyUser("Заблокировано: \(ruleName)", type: .blacklist)
                return
            }
            
            // 3. Создание элемента и добавление в буфер
            let item = ClipItem(
                id: UUID(),
                content: string,
                timestamp: Date(),
                sourceApp: NSWorkspace.shared.frontmostApplication?.localizedName,
                contentType: detectContentType(string)
            )
            
            delegate?.clipboardDidChange(item)
        }
    }
    
    private func notifyUser(_ message: String, type: NotificationType) {
        let notification = UNMutableNotificationContent()
        notification.title = "ClipStack"
        notification.body = message
        notification.sound = type == .security ? .default : nil
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: notification,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}

enum NotificationType {
    case security
    case blacklist
}
```

### Storage

```swift
protocol BlacklistStorage {
    func save(_ rules: [BlacklistRule])
    func load() -> [BlacklistRule]
}

class UserDefaultsBlacklistStorage: BlacklistStorage {
    private let key = "clipstack.blacklist.rules"
    
    func save(_ rules: [BlacklistRule]) {
        if let encoded = try? JSONEncoder().encode(rules) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func load() -> [BlacklistRule] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let rules = try? JSONDecoder().decode([BlacklistRule].self, from: data)
        else {
            return []
        }
        return rules
    }
}
```

## 🎨 UI/UX

### Settings → Blacklist вкладка

```
┌────────────────────────────────────────────┐
│ Blacklist Settings                         │
├────────────────────────────────────────────┤
│                                            │
│ Блокировать копирование, если текст        │
│ содержит любую из этих подстрок:           │
│                                            │
│ ┌────────────────────────────────────────┐ │
│ │ 🔍 Поиск правил...                     │ │
│ └────────────────────────────────────────┘ │
│                                            │
│ ┌────────────────────────────────────────┐ │
│ │ ☑ localhost                       [×]  │ │
│ │   Локальные URL                        │ │
│ │   Case insensitive                     │ │
│ ├────────────────────────────────────────┤ │
│ │ ☑ 127.0.0.1                       [×]  │ │
│ │   Локальный IP адрес                   │ │
│ │   Case insensitive                     │ │
│ ├────────────────────────────────────────┤ │
│ │ ☑ tmp                             [×]  │ │
│ │   Временные файлы                      │ │
│ │   Case insensitive                     │ │
│ ├────────────────────────────────────────┤ │
│ │ ☑ CONFIDENTIAL                    [×]  │ │
│ │   Конфиденциальная информация          │ │
│ │   Case SENSITIVE                       │ │
│ └────────────────────────────────────────┘ │
│                                            │
│ [+ Добавить правило]                       │
│                                            │
│ ┌────────────────────────────────────────┐ │
│ │ Пресеты:                               │ │
│ │ • Разработка (localhost, tmp, test)    │ │
│ │ • Конфиденциальность (SECRET, PRIVATE) │ │
│ │ • Временные файлы (tmp, temp, draft)   │ │
│ └────────────────────────────────────────┘ │
│                                            │
│ [Загрузить пресет ▼] [Экспорт] [Импорт]   │
│                                            │
└────────────────────────────────────────────┘
```

### Диалог добавления правила

```
┌────────────────────────────────────┐
│ Добавить правило блокировки        │
├────────────────────────────────────┤
│                                    │
│ Подстрока для блокировки:          │
│ ┌────────────────────────────────┐ │
│ │ localhost                      │ │
│ └────────────────────────────────┘ │
│                                    │
│ Описание (опционально):            │
│ ┌────────────────────────────────┐ │
│ │ Локальные URL разработки       │ │
│ └────────────────────────────────┘ │
│                                    │
│ ☑ Учитывать регистр               │
│ ☑ Включить правило сразу          │
│                                    │
│ Примеры блокируемых значений:      │
│ • http://localhost:3000            │
│ • localhost/api/test               │
│                                    │
│        [Отмена]  [Добавить]        │
└────────────────────────────────────┘
```

### Уведомление о блокировке

```
┌────────────────────────────────┐
│ 📋 ClipStack                   │
├────────────────────────────────┤
│ Заблокировано: Локальные URL   │
│                                │
│ Содержит: "localhost"          │
│                                │
│ [Настройки] [Игнорировать раз] │
└────────────────────────────────┘
```

## ⚙️ Настройки и опции

### Глобальные настройки

```swift
struct BlacklistSettings: Codable {
    var isEnabled: Bool = true
    var showNotifications: Bool = true
    var notificationSound: Bool = false
    var logBlockedItems: Bool = true
    var allowTemporaryBypass: Bool = true  // Cmd+Option+C обходит фильтр
}
```

### Временный обход фильтра

Пользователь может временно обойти чёрный список:
- **Горячая клавиша**: `Cmd+Option+C` вместо `Cmd+C`
- **Действие**: Копирование игнорирует чёрный список один раз
- **Уведомление**: "Фильтр обойдён для этого копирования"

## 📊 Статистика

### Отслеживаемые метрики

```swift
struct BlacklistStatistics: Codable {
    var totalBlocked: Int = 0
    var blockedByRule: [UUID: Int] = [:]  // rule.id -> count
    var lastBlockedAt: Date?
    var mostBlockedPattern: String?
    
    mutating func recordBlock(rule: BlacklistRule) {
        totalBlocked += 1
        blockedByRule[rule.id, default: 0] += 1
        lastBlockedAt = Date()
    }
}
```

### UI статистики

```
┌────────────────────────────────────┐
│ Статистика блокировок              │
├────────────────────────────────────┤
│ Всего заблокировано: 127           │
│ За последние 7 дней: 23            │
│                                    │
│ Топ правил:                        │
│ 1. localhost (45 блокировок)       │
│ 2. tmp (32 блокировки)             │
│ 3. CONFIDENTIAL (18 блокировок)    │
│                                    │
│ [Сбросить статистику]              │
└────────────────────────────────────┘
```

## 🧪 Тестирование

### Unit тесты

```swift
class BlacklistManagerTests: XCTestCase {
    var manager: BlacklistManager!
    
    override func setUp() {
        manager = BlacklistManager(storage: MockBlacklistStorage())
    }
    
    func testSimpleBlacklist() {
        let rule = BlacklistRule(pattern: "localhost")
        manager.addRule(rule)
        
        let result = manager.isBlacklisted("http://localhost:3000")
        XCTAssertTrue(result.blocked)
        XCTAssertEqual(result.matchedRule?.pattern, "localhost")
    }
    
    func testCaseSensitivity() {
        let rule = BlacklistRule(
            pattern: "SECRET",
            isCaseSensitive: true
        )
        manager.addRule(rule)
        
        XCTAssertTrue(manager.isBlacklisted("SECRET document").blocked)
        XCTAssertFalse(manager.isBlacklisted("secret document").blocked)
    }
    
    func testDisabledRule() {
        var rule = BlacklistRule(pattern: "test")
        rule.isEnabled = false
        manager.addRule(rule)
        
        XCTAssertFalse(manager.isBlacklisted("test content").blocked)
    }
    
    func testMultipleRules() {
        manager.addRule(BlacklistRule(pattern: "localhost"))
        manager.addRule(BlacklistRule(pattern: "tmp"))
        
        XCTAssertTrue(manager.isBlacklisted("localhost:3000").blocked)
        XCTAssertTrue(manager.isBlacklisted("tmp_file.txt").blocked)
        XCTAssertFalse(manager.isBlacklisted("production.com").blocked)
    }
}
```

## 📋 Пресеты правил

### Разработка
```swift
let developmentPreset: [BlacklistRule] = [
    BlacklistRule(pattern: "localhost", description: "Локальный сервер"),
    BlacklistRule(pattern: "127.0.0.1", description: "Локальный IP"),
    BlacklistRule(pattern: "0.0.0.0", description: "Все интерфейсы"),
    BlacklistRule(pattern: "tmp", description: "Временные файлы"),
    BlacklistRule(pattern: "test", description: "Тестовые данные"),
    BlacklistRule(pattern: "debug", description: "Отладочная информация"),
]
```

### Конфиденциальность
```swift
let privacyPreset: [BlacklistRule] = [
    BlacklistRule(pattern: "CONFIDENTIAL", isCaseSensitive: true),
    BlacklistRule(pattern: "SECRET", isCaseSensitive: true),
    BlacklistRule(pattern: "PRIVATE", isCaseSensitive: true),
    BlacklistRule(pattern: "INTERNAL", isCaseSensitive: true),
    BlacklistRule(pattern: "DO NOT SHARE", isCaseSensitive: true),
]
```

### Временные файлы
```swift
let temporaryFilesPreset: [BlacklistRule] = [
    BlacklistRule(pattern: "tmp"),
    BlacklistRule(pattern: "temp"),
    BlacklistRule(pattern: "draft"),
    BlacklistRule(pattern: ".bak"),
    BlacklistRule(pattern: "~"),
    BlacklistRule(pattern: ".swp"),
]
```

## 🔄 Импорт/Экспорт

### Формат файла (JSON)

```json
{
  "version": "1.0",
  "rules": [
    {
      "id": "uuid-here",
      "pattern": "localhost",
      "isEnabled": true,
      "isCaseSensitive": false,
      "description": "Локальные URL",
      "createdAt": "2026-01-29T12:00:00Z"
    }
  ]
}
```

### Функции импорта/экспорта

```swift
extension BlacklistManager {
    func exportToFile(url: URL) throws {
        let export = BlacklistExport(version: "1.0", rules: rules)
        let data = try JSONEncoder().encode(export)
        try data.write(to: url)
    }
    
    func importFromFile(url: URL, merge: Bool = false) throws {
        let data = try Data(contentsOf: url)
        let export = try JSONDecoder().decode(BlacklistExport.self, from: data)
        
        if merge {
            rules.append(contentsOf: export.rules)
        } else {
            rules = export.rules
        }
        save()
    }
}
```

## 🎯 Приоритет реализации

### MVP (v1.0)
- [x] Базовая модель BlacklistRule
- [x] BlacklistManager с простой проверкой
- [x] Интеграция с ClipboardMonitor
- [x] UI для добавления/удаления правил
- [x] Сохранение в UserDefaults

### v1.1
- [ ] Статистика блокировок
- [ ] Пресеты правил
- [ ] Импорт/экспорт
- [ ] Временный обход (Cmd+Option+C)

### v1.2
- [ ] Regex поддержка
- [ ] Группировка правил
- [ ] Расписание (временные правила)
- [ ] Синхронизация между устройствами

---

**Версия документа**: 1.0  
**Дата создания**: 2026-01-29  
**Статус**: Ready for Implementation