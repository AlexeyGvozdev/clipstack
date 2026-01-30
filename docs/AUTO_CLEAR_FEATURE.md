# Функционал автоматической очистки буфера (Auto-Clear Timer)

## 🎯 Назначение

Автоматическая очистка буфера позволяет настроить временной интервал, по истечении которого весь буфер будет автоматически очищен. Это полезно для:
- Поддержания актуальности данных в буфере
- Автоматического освобождения памяти
- Обеспечения приватности (старые данные не накапливаются)
- Предотвращения случайной вставки устаревших данных

## 💡 Примеры использования

### Пример 1: Рабочая сессия
```
Настройка: Очистка через 30 минут

09:00 - Начали работу, копируете данные
09:15 - Буфер содержит 10 элементов
09:30 - Автоматическая очистка! Буфер пуст
09:31 - Начинаете новую задачу с чистым буфером
```

### Пример 2: Конфиденциальная работа
```
Настройка: Очистка через 5 минут

14:00 - Копируете конфиденциальные данные
14:03 - Используете данные из буфера
14:05 - Автоматическая очистка! Данные удалены
```

### Пример 3: Длительная работа
```
Настройка: Очистка через 2 часа

10:00 - Начали работу над проектом
11:30 - Буфер содержит много данных
12:00 - Автоматическая очистка! Новая сессия
```

## 🏗️ Техническая реализация

### Модель данных

```swift
struct AutoClearSettings: Codable {
    var isEnabled: Bool = false
    var interval: TimeInterval = 1800  // 30 минут по умолчанию
    var notifyBeforeClear: Bool = true
    var notificationTime: TimeInterval = 60  // Уведомить за 1 минуту
    var clearOnlyOldItems: Bool = false  // Очищать только старые элементы
    var itemMaxAge: TimeInterval = 3600  // Максимальный возраст элемента
    
    enum Preset: String, CaseIterable {
        case fiveMinutes = "5 минут"
        case fifteenMinutes = "15 минут"
        case thirtyMinutes = "30 минут"
        case oneHour = "1 час"
        case twoHours = "2 часа"
        case fourHours = "4 часа"
        case never = "Никогда"
        
        var interval: TimeInterval? {
            switch self {
            case .fiveMinutes: return 300
            case .fifteenMinutes: return 900
            case .thirtyMinutes: return 1800
            case .oneHour: return 3600
            case .twoHours: return 7200
            case .fourHours: return 14400
            case .never: return nil
            }
        }
    }
}

class AutoClearManager: ObservableObject {
    @Published private(set) var settings: AutoClearSettings
    @Published private(set) var timeUntilClear: TimeInterval?
    @Published private(set) var isCountingDown: Bool = false
    
    private var clearTimer: Timer?
    private var notificationTimer: Timer?
    private var countdownTimer: Timer?
    private var lastActivityTime: Date?
    
    weak var delegate: AutoClearManagerDelegate?
    
    init(settings: AutoClearSettings = AutoClearSettings()) {
        self.settings = settings
    }
    
    // MARK: - Public API
    
    func start() {
        guard settings.isEnabled else { return }
        resetTimer()
    }
    
    func stop() {
        clearTimer?.invalidate()
        notificationTimer?.invalidate()
        countdownTimer?.invalidate()
        isCountingDown = false
        timeUntilClear = nil
    }
    
    func resetTimer() {
        stop()
        
        guard settings.isEnabled else { return }
        
        lastActivityTime = Date()
        isCountingDown = true
        timeUntilClear = settings.interval
        
        // Таймер для очистки
        clearTimer = Timer.scheduledTimer(
            withTimeInterval: settings.interval,
            repeats: false
        ) { [weak self] _ in
            self?.performClear()
        }
        
        // Таймер для уведомления
        if settings.notifyBeforeClear {
            let notificationDelay = settings.interval - settings.notificationTime
            if notificationDelay > 0 {
                notificationTimer = Timer.scheduledTimer(
                    withTimeInterval: notificationDelay,
                    repeats: false
                ) { [weak self] _ in
                    self?.notifyBeforeClear()
                }
            }
        }
        
        // Таймер обратного отсчёта (обновление UI каждую секунду)
        countdownTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { [weak self] _ in
            self?.updateCountdown()
        }
    }
    
    func updateSettings(_ newSettings: AutoClearSettings) {
        settings = newSettings
        saveSettings()
        
        if settings.isEnabled {
            resetTimer()
        } else {
            stop()
        }
    }
    
    func postponeClear(by interval: TimeInterval) {
        guard isCountingDown else { return }
        
        // Продлить таймер
        if let currentTime = timeUntilClear {
            timeUntilClear = currentTime + interval
            resetTimer()
        }
    }
    
    func clearNow() {
        performClear()
    }
    
    // MARK: - Private Methods
    
    private func performClear() {
        stop()
        
        if settings.clearOnlyOldItems {
            // Очистить только старые элементы
            delegate?.autoClearShouldClearOldItems(olderThan: settings.itemMaxAge)
        } else {
            // Очистить весь буфер
            delegate?.autoClearShouldClearBuffer()
        }
        
        // Уведомление о выполненной очистке
        notifyClearCompleted()
        
        // Перезапустить таймер
        if settings.isEnabled {
            resetTimer()
        }
    }
    
    private func updateCountdown() {
        guard let lastActivity = lastActivityTime else { return }
        
        let elapsed = Date().timeIntervalSince(lastActivity)
        let remaining = settings.interval - elapsed
        
        if remaining > 0 {
            timeUntilClear = remaining
        } else {
            timeUntilClear = 0
        }
    }
    
    private func notifyBeforeClear() {
        let content = UNMutableNotificationContent()
        content.title = "ClipStack"
        content.body = "Буфер будет очищен через \(Int(settings.notificationTime)) секунд"
        content.sound = .default
        content.categoryIdentifier = "AUTO_CLEAR_WARNING"
        
        let request = UNNotificationRequest(
            identifier: "auto-clear-warning",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func notifyClearCompleted() {
        let content = UNMutableNotificationContent()
        content.title = "ClipStack"
        content.body = "Буфер автоматически очищен"
        content.sound = nil
        
        let request = UNNotificationRequest(
            identifier: "auto-clear-completed",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "clipstack.autoclear.settings")
        }
    }
}

protocol AutoClearManagerDelegate: AnyObject {
    func autoClearShouldClearBuffer()
    func autoClearShouldClearOldItems(olderThan age: TimeInterval)
}
```

### Интеграция с ClipBuffer

```swift
class ClipBuffer: ClipBufferProtocol {
    // ... существующий код ...
    
    private let autoClearManager: AutoClearManager
    
    init(autoClearManager: AutoClearManager) {
        self.autoClearManager = autoClearManager
        self.autoClearManager.delegate = self
    }
    
    func push(_ item: ClipItem) {
        storage.append(item)
        
        // Сбросить таймер при новой активности
        autoClearManager.resetTimer()
        
        // ... остальная логика ...
    }
}

extension ClipBuffer: AutoClearManagerDelegate {
    func autoClearShouldClearBuffer() {
        clear()
    }
    
    func autoClearShouldClearOldItems(olderThan age: TimeInterval) {
        let cutoffDate = Date().addingTimeInterval(-age)
        storage.removeAll { $0.timestamp < cutoffDate }
    }
}
```

## 🎨 UI/UX

### Settings → Auto-Clear вкладка

```
┌────────────────────────────────────────────┐
│ Auto-Clear Settings                        │
├────────────────────────────────────────────┤
│                                            │
│ ☑ Включить автоматическую очистку         │
│                                            │
│ Очищать буфер через:                       │
│ ┌────────────────────────────────────────┐ │
│ │ ○ 5 минут                              │ │
│ │ ○ 15 минут                             │ │
│ │ ● 30 минут                             │ │
│ │ ○ 1 час                                │ │
│ │ ○ 2 часа                               │ │
│ │ ○ 4 часа                               │ │
│ │ ○ Никогда                              │ │
│ │ ○ Настроить... [___] минут             │ │
│ └────────────────────────────────────────┘ │
│                                            │
│ Дополнительные настройки:                  │
│ ☑ Уведомлять перед очисткой                │
│   За [60] секунд до очистки                │
│                                            │
│ ☐ Очищать только старые элементы          │
│   Старше [60] минут                        │
│                                            │
│ ☑ Сбрасывать таймер при копировании       │
│                                            │
│ Текущий статус:                            │
│ ┌────────────────────────────────────────┐ │
│ │ ⏱️  До очистки: 23:45                  │ │
│ │                                        │ │
│ │ [Очистить сейчас] [Отложить на 10 мин]│ │
│ └────────────────────────────────────────┘ │
│                                            │
└────────────────────────────────────────────┘
```

### Menu Bar индикатор

```
┌─────────────┐
│  📋 [5] ⏱️  │  ← Иконка таймера показывает активность
└─────────────┘

При наведении:
┌──────────────────────┐
│ 5 элементов в буфере │
│ Очистка через 23:45  │
└──────────────────────┘
```

### Уведомление перед очисткой

```
┌────────────────────────────────┐
│ 📋 ClipStack                   │
├────────────────────────────────┤
│ Буфер будет очищен через 60 с  │
│                                │
│ [Отложить] [Очистить сейчас]   │
└────────────────────────────────┘
```

### Уведомление после очистки

```
┌────────────────────────────────┐
│ 📋 ClipStack                   │
├────────────────────────────────┤
│ Буфер автоматически очищен     │
│ Удалено элементов: 12          │
└────────────────────────────────┘
```

## ⚙️ Режимы работы

### 1. Полная очистка (по умолчанию)
```swift
settings.clearOnlyOldItems = false
```
- Очищает весь буфер полностью
- Простой и предсказуемый режим
- Рекомендуется для большинства пользователей

### 2. Очистка только старых элементов
```swift
settings.clearOnlyOldItems = true
settings.itemMaxAge = 3600  // 1 час
```
- Удаляет только элементы старше указанного возраста
- Новые элементы остаются в буфере
- Полезно для длительных рабочих сессий

### 3. Сброс таймера при активности
```swift
// При каждом копировании таймер сбрасывается
buffer.push(item)  // → autoClearManager.resetTimer()
```
- Таймер перезапускается при каждом копировании
- Буфер очищается только при отсутствии активности
- Идеально для активной работы

## 📊 Статистика

### Отслеживаемые метрики

```swift
struct AutoClearStatistics: Codable {
    var totalClears: Int = 0
    var itemsCleared: Int = 0
    var lastClearAt: Date?
    var averageItemsPerClear: Double = 0
    var postponeCount: Int = 0
    
    mutating func recordClear(itemCount: Int) {
        totalClears += 1
        itemsCleared += itemCount
        lastClearAt = Date()
        averageItemsPerClear = Double(itemsCleared) / Double(totalClears)
    }
    
    mutating func recordPostpone() {
        postponeCount += 1
    }
}
```

### UI статистики

```
┌────────────────────────────────────┐
│ Статистика автоочистки             │
├────────────────────────────────────┤
│ Всего очисток: 47                  │
│ Удалено элементов: 523             │
│ Среднее за очистку: 11.1           │
│ Последняя очистка: 2 часа назад    │
│ Отложено очисток: 12               │
│                                    │
│ [Сбросить статистику]              │
└────────────────────────────────────┘
```

## 🔔 Уведомления

### Категории уведомлений

```swift
// Регистрация категорий
let warningCategory = UNNotificationCategory(
    identifier: "AUTO_CLEAR_WARNING",
    actions: [
        UNNotificationAction(
            identifier: "POSTPONE",
            title: "Отложить на 10 минут"
        ),
        UNNotificationAction(
            identifier: "CLEAR_NOW",
            title: "Очистить сейчас",
            options: .destructive
        )
    ],
    intentIdentifiers: []
)

UNUserNotificationCenter.current().setNotificationCategories([warningCategory])
```

### Обработка действий

```swift
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        switch response.actionIdentifier {
        case "POSTPONE":
            autoClearManager.postponeClear(by: 600)  // 10 минут
        case "CLEAR_NOW":
            autoClearManager.clearNow()
        default:
            break
        }
        completionHandler()
    }
}
```

## 🧪 Тестирование

### Unit тесты

```swift
class AutoClearManagerTests: XCTestCase {
    var manager: AutoClearManager!
    var delegate: MockAutoClearDelegate!
    
    override func setUp() {
        var settings = AutoClearSettings()
        settings.isEnabled = true
        settings.interval = 5  // 5 секунд для тестов
        
        manager = AutoClearManager(settings: settings)
        delegate = MockAutoClearDelegate()
        manager.delegate = delegate
    }
    
    func testAutoClearAfterInterval() {
        let expectation = XCTestExpectation(description: "Auto clear triggered")
        
        delegate.onClear = {
            expectation.fulfill()
        }
        
        manager.start()
        
        wait(for: [expectation], timeout: 6.0)
        XCTAssertTrue(delegate.clearCalled)
    }
    
    func testResetTimerOnActivity() {
        manager.start()
        
        // Подождать 3 секунды
        Thread.sleep(forTimeInterval: 3)
        
        // Сбросить таймер
        manager.resetTimer()
        
        // Подождать ещё 3 секунды (всего 6, но таймер сброшен)
        Thread.sleep(forTimeInterval: 3)
        
        // Очистка не должна произойти
        XCTAssertFalse(delegate.clearCalled)
    }
    
    func testPostponeClear() {
        manager.start()
        
        // Отложить на 5 секунд
        manager.postponeClear(by: 5)
        
        // Подождать 6 секунд (оригинальный интервал)
        Thread.sleep(forTimeInterval: 6)
        
        // Очистка не должна произойти
        XCTAssertFalse(delegate.clearCalled)
    }
    
    func testClearOnlyOldItems() {
        var settings = manager.settings
        settings.clearOnlyOldItems = true
        settings.itemMaxAge = 60
        manager.updateSettings(settings)
        
        manager.start()
        
        // Симулировать очистку
        manager.clearNow()
        
        XCTAssertTrue(delegate.clearOldItemsCalled)
        XCTAssertEqual(delegate.maxAge, 60)
    }
}
```

## 📋 Пресеты

### Быстрые настройки

```swift
extension AutoClearSettings {
    static let quickWork = AutoClearSettings(
        isEnabled: true,
        interval: 900,  // 15 минут
        notifyBeforeClear: true,
        notificationTime: 60
    )
    
    static let confidential = AutoClearSettings(
        isEnabled: true,
        interval: 300,  // 5 минут
        notifyBeforeClear: false,
        clearOnlyOldItems: false
    )
    
    static let longSession = AutoClearSettings(
        isEnabled: true,
        interval: 7200,  // 2 часа
        notifyBeforeClear: true,
        notificationTime: 300,  // 5 минут
        clearOnlyOldItems: true,
        itemMaxAge: 3600  // 1 час
    )
    
    static let disabled = AutoClearSettings(
        isEnabled: false
    )
}
```

## 🎯 Приоритет реализации

### MVP (v1.0)
- [x] Базовая модель AutoClearSettings
- [x] AutoClearManager с таймером
- [x] Интеграция с ClipBuffer
- [x] UI для включения/выключения
- [x] Базовые пресеты (5, 15, 30 мин, 1, 2, 4 часа)

### v1.1
- [ ] Уведомления перед очисткой
- [ ] Действия в уведомлениях (отложить, очистить)
- [ ] Индикатор обратного отсчёта в menu bar
- [ ] Статистика очисток

### v1.2
- [ ] Режим "только старые элементы"
- [ ] Настраиваемый интервал
- [ ] Расписание очисток (например, каждый день в 18:00)
- [ ] Экспорт перед очисткой

---

**Версия документа**: 1.0  
**Дата создания**: 2026-01-29  
**Статус**: Ready for Implementation