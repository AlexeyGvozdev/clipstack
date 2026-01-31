//
//  AutoClearManager.swift
//  ClipStack
//
//  Created by ClipStack on 2026-01-31.
//

import Foundation
import Combine
import UserNotifications

/// Менеджер автоматической очистки буфера
class AutoClearManager: ObservableObject {
    // MARK: - Published Properties
    
    /// Текущие настройки
    @Published private(set) var settings: AutoClearSettings
    
    /// Время до очистки в секундах
    @Published private(set) var timeUntilClear: TimeInterval?
    
    /// Идёт ли обратный отсчёт
    @Published private(set) var isCountingDown: Bool = false
    
    // MARK: - Properties
    
    private var clearTimer: Timer?
    private var notificationTimer: Timer?
    private var countdownTimer: Timer?
    private var lastActivityTime: Date?
    
    weak var delegate: AutoClearManagerDelegate?
    
    private let settingsManager: SettingsManager
    private let settingsKey = "clipstack.autoclear.settings"
    
    // MARK: - Initialization
    
    init(settings: AutoClearSettings = AutoClearSettings(), settingsManager: SettingsManager = .shared) {
        self.settings = settings
        self.settingsManager = settingsManager
        loadSettings()
    }
    
    deinit {
        stop()
    }
    
    // MARK: - Public API
    
    /// Запустить автоочистку
    func start() {
        guard settings.isEnabled && settingsManager.enableAutoClear else { return }
        resetTimer()
    }
    
    /// Остановить автоочистку
    func stop() {
        clearTimer?.invalidate()
        clearTimer = nil
        
        notificationTimer?.invalidate()
        notificationTimer = nil
        
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        isCountingDown = false
        timeUntilClear = nil
    }
    
    /// Сбросить таймер (перезапустить отсчёт)
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
        
        // Таймер для уведомления перед очисткой
        if settings.notifyBeforeClear && settings.notificationTime > 0 {
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
    
    /// Обновить настройки
    /// - Parameter newSettings: Новые настройки
    func updateSettings(_ newSettings: AutoClearSettings) {
        settings = newSettings
        saveSettings()
        
        // Also update SettingsManager enableAutoClear flag
        settingsManager.enableAutoClear = newSettings.isEnabled
        
        if settings.isEnabled && settingsManager.enableAutoClear {
            resetTimer()
        } else {
            stop()
        }
    }
    
    /// Отложить очистку на указанное время
    /// - Parameter interval: Интервал отсрочки в секундах
    func postponeClear(by interval: TimeInterval) {
        guard isCountingDown else { return }
        
        // Продлить таймер
        if let currentTime = timeUntilClear {
            let newInterval = currentTime + interval
            var newSettings = settings
            newSettings.interval = newInterval
            updateSettings(newSettings)
        }
    }
    
    /// Очистить буфер немедленно
    func clearNow() {
        performClear()
    }
    
    /// Обработать активность (копирование)
    func handleActivity() {
        guard settings.resetTimerOnActivity && settingsManager.enableAutoClear else { return }
        resetTimer()
    }
    
    // MARK: - Private Methods
    
    private func performClear() {
        stop()
        
        let itemCount: Int
        
        if settings.clearOnlyOldItems {
            // Очистить только старые элементы
            itemCount = delegate?.autoClearShouldClearOldItems(olderThan: settings.itemMaxAge) ?? 0
        } else {
            // Очистить весь буфер
            itemCount = delegate?.autoClearShouldClearBuffer() ?? 0
        }
        
        // Уведомление о выполненной очистке
        notifyClearCompleted(itemCount: itemCount)
        
        // Перезапустить таймер, если автоочистка всё ещё включена
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
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to show notification: \(error)")
            }
        }
    }
    
    private func notifyClearCompleted(itemCount: Int) {
        let content = UNMutableNotificationContent()
        content.title = "ClipStack"
        content.body = "Буфер автоматически очищен. Удалено элементов: \(itemCount)"
        content.sound = nil
        
        let request = UNNotificationRequest(
            identifier: "auto-clear-completed",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to show notification: \(error)")
            }
        }
    }
    
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
    
    private func loadSettings() {
        guard let data = UserDefaults.standard.data(forKey: settingsKey),
              let loaded = try? JSONDecoder().decode(AutoClearSettings.self, from: data) else {
            return
        }
        settings = loaded
    }
    
    // MARK: - Computed Properties
    
    /// Форматированное время до очистки
    var formattedTimeUntilClear: String {
        guard let time = timeUntilClear else { return "--:--" }
        
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - AutoClearManagerDelegate

protocol AutoClearManagerDelegate: AnyObject {
    /// Должен очистить весь буфер
    /// - Returns: Количество удалённых элементов
    @discardableResult
    func autoClearShouldClearBuffer() -> Int
    
    /// Должен очистить только старые элементы
    /// - Parameter age: Максимальный возраст элемента в секундах
    /// - Returns: Количество удалённых элементов
    @discardableResult
    func autoClearShouldClearOldItems(olderThan age: TimeInterval) -> Int
}