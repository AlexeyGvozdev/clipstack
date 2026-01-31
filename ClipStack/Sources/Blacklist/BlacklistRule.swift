//
//  BlacklistRule.swift
//  ClipStack
//
//  Created by ClipStack on 2026-01-31.
//

import Foundation

/// Правило чёрного списка для фильтрации контента
struct BlacklistRule: Identifiable, Codable, Equatable {
    /// Уникальный идентификатор правила
    let id: UUID
    
    /// Паттерн для поиска в контенте
    var pattern: String
    
    /// Включено ли правило
    var isEnabled: Bool
    
    /// Учитывать ли регистр при поиске
    var isCaseSensitive: Bool
    
    /// Описание правила (опционально)
    var description: String?
    
    /// Дата создания правила
    let createdAt: Date
    
    /// Инициализатор правила
    /// - Parameters:
    ///   - pattern: Паттерн для поиска
    ///   - isEnabled: Включено ли правило (по умолчанию true)
    ///   - isCaseSensitive: Учитывать ли регистр (по умолчанию false)
    ///   - description: Описание правила (опционально)
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
    
    /// Инициализатор для декодирования
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        pattern = try container.decode(String.self, forKey: .pattern)
        isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
        isCaseSensitive = try container.decode(Bool.self, forKey: .isCaseSensitive)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
}

// MARK: - Preset Rules

extension BlacklistRule {
    /// Пресет правил для разработки
    static var developmentPreset: [BlacklistRule] {
        [
            BlacklistRule(pattern: "localhost", description: "Локальный сервер"),
            BlacklistRule(pattern: "127.0.0.1", description: "Локальный IP"),
            BlacklistRule(pattern: "0.0.0.0", description: "Все интерфейсы"),
            BlacklistRule(pattern: "tmp", description: "Временные файлы"),
            BlacklistRule(pattern: "test", description: "Тестовые данные"),
            BlacklistRule(pattern: "debug", description: "Отладочная информация")
        ]
    }
    
    /// Пресет правил для конфиденциальности
    static var privacyPreset: [BlacklistRule] {
        [
            BlacklistRule(
                pattern: "CONFIDENTIAL",
                isCaseSensitive: true,
                description: "Конфиденциальная информация"
            ),
            BlacklistRule(
                pattern: "SECRET",
                isCaseSensitive: true,
                description: "Секретная информация"
            ),
            BlacklistRule(
                pattern: "PRIVATE",
                isCaseSensitive: true,
                description: "Приватная информация"
            ),
            BlacklistRule(
                pattern: "INTERNAL",
                isCaseSensitive: true,
                description: "Внутренняя информация"
            ),
            BlacklistRule(
                pattern: "DO NOT SHARE",
                isCaseSensitive: true,
                description: "Не для распространения"
            )
        ]
    }
    
    /// Пресет правил для временных файлов
    static var temporaryFilesPreset: [BlacklistRule] {
        [
            BlacklistRule(pattern: "tmp", description: "Временные файлы"),
            BlacklistRule(pattern: "temp", description: "Временные файлы"),
            BlacklistRule(pattern: "draft", description: "Черновики"),
            BlacklistRule(pattern: ".bak", description: "Резервные копии"),
            BlacklistRule(pattern: "~", description: "Временные файлы редактора"),
            BlacklistRule(pattern: ".swp", description: "Swap файлы")
        ]
    }
}