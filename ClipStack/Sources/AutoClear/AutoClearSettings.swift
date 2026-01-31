//
//  AutoClearSettings.swift
//  ClipStack
//
//  Created by ClipStack on 2026-01-31.
//

import Foundation

/// Настройки автоматической очистки буфера
struct AutoClearSettings: Codable, Equatable {
    /// Включена ли автоочистка
    var isEnabled: Bool = false
    
    /// Интервал очистки в секундах (по умолчанию 30 минут)
    var interval: TimeInterval = 1800
    
    /// Уведомлять ли перед очисткой
    var notifyBeforeClear: Bool = true
    
    /// За сколько секунд уведомить перед очисткой (по умолчанию 60 секунд)
    var notificationTime: TimeInterval = 60
    
    /// Очищать только старые элементы
    var clearOnlyOldItems: Bool = false
    
    /// Максимальный возраст элемента в секундах (по умолчанию 1 час)
    var itemMaxAge: TimeInterval = 3600
    
    /// Сбрасывать таймер при копировании
    var resetTimerOnActivity: Bool = true
    
    /// Пресеты интервалов очистки
    enum Preset: String, CaseIterable, Codable {
        case fiveMinutes = "5 минут"
        case fifteenMinutes = "15 минут"
        case thirtyMinutes = "30 минут"
        case oneHour = "1 час"
        case twoHours = "2 часа"
        case fourHours = "4 часа"
        case never = "Никогда"
        
        /// Интервал в секундах для пресета
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
        
        /// Создать настройки из пресета
        func makeSettings() -> AutoClearSettings {
            var settings = AutoClearSettings()
            if let interval = self.interval {
                settings.isEnabled = true
                settings.interval = interval
            } else {
                settings.isEnabled = false
            }
            return settings
        }
    }
}

// MARK: - Preset Configurations

extension AutoClearSettings {
    /// Быстрая работа (15 минут)
    static let quickWork = AutoClearSettings(
        isEnabled: true,
        interval: 900,
        notifyBeforeClear: true,
        notificationTime: 60,
        clearOnlyOldItems: false,
        itemMaxAge: 3600,
        resetTimerOnActivity: true
    )
    
    /// Конфиденциальная работа (5 минут, без уведомлений)
    static let confidential = AutoClearSettings(
        isEnabled: true,
        interval: 300,
        notifyBeforeClear: false,
        notificationTime: 60,
        clearOnlyOldItems: false,
        itemMaxAge: 3600,
        resetTimerOnActivity: false
    )
    
    /// Длительная сессия (2 часа, только старые элементы)
    static let longSession = AutoClearSettings(
        isEnabled: true,
        interval: 7200,
        notifyBeforeClear: true,
        notificationTime: 300,
        clearOnlyOldItems: true,
        itemMaxAge: 3600,
        resetTimerOnActivity: true
    )
    
    /// Отключено
    static let disabled = AutoClearSettings(
        isEnabled: false
    )
}