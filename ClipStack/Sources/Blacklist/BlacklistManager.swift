//
//  BlacklistManager.swift
//  ClipStack
//
//  Created by ClipStack on 2026-01-31.
//

import Foundation
import Combine

/// Менеджер чёрного списка для фильтрации контента
class BlacklistManager: ObservableObject {
    /// Список правил чёрного списка
    @Published private(set) var rules: [BlacklistRule] = []
    
    /// Хранилище правил
    private let storage: BlacklistStorage
    
    /// Инициализатор
    /// - Parameter storage: Хранилище для правил (по умолчанию UserDefaults)
    init(storage: BlacklistStorage = UserDefaultsBlacklistStorage()) {
        self.storage = storage
        self.rules = storage.load()
    }
    
    // MARK: - Public API
    
    /// Добавить правило в чёрный список
    /// - Parameter rule: Правило для добавления
    func addRule(_ rule: BlacklistRule) {
        rules.append(rule)
        save()
    }
    
    /// Удалить правило по ID
    /// - Parameter id: ID правила для удаления
    func removeRule(id: UUID) {
        rules.removeAll { $0.id == id }
        save()
    }
    
    /// Обновить существующее правило
    /// - Parameter rule: Обновлённое правило
    func updateRule(_ rule: BlacklistRule) {
        if let index = rules.firstIndex(where: { $0.id == rule.id }) {
            rules[index] = rule
            save()
        }
    }
    
    /// Переключить состояние правила (включено/выключено)
    /// - Parameter id: ID правила
    func toggleRule(id: UUID) {
        if let index = rules.firstIndex(where: { $0.id == id }) {
            rules[index].isEnabled.toggle()
            save()
        }
    }
    
    /// Проверить, содержит ли контент запрещённые подстроки
    /// - Parameter content: Контент для проверки
    /// - Returns: Кортеж (заблокирован, совпавшее правило)
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
    
    /// Очистить все правила
    func clearAll() {
        rules.removeAll()
        save()
    }
    
    // MARK: - Preset Rules
    
    /// Загрузить пресет правил для разработки
    func loadDevelopmentPreset() {
        rules.append(contentsOf: BlacklistRule.developmentPreset)
        save()
    }
    
    /// Загрузить пресет правил для конфиденциальности
    func loadPrivacyPreset() {
        rules.append(contentsOf: BlacklistRule.privacyPreset)
        save()
    }
    
    /// Загрузить пресет правил для временных файлов
    func loadTemporaryFilesPreset() {
        rules.append(contentsOf: BlacklistRule.temporaryFilesPreset)
        save()
    }
    
    /// Загрузить все дефолтные правила
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
    
    // MARK: - Import/Export
    
    /// Экспортировать правила в JSON файл
    /// - Parameter url: URL файла для экспорта
    /// - Throws: Ошибка при кодировании или записи
    func exportToFile(url: URL) throws {
        let export = BlacklistExport(version: "1.0", rules: rules)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(export)
        try data.write(to: url)
    }
    
    /// Импортировать правила из JSON файла
    /// - Parameters:
    ///   - url: URL файла для импорта
    ///   - merge: Объединить с существующими правилами (true) или заменить (false)
    /// - Throws: Ошибка при чтении или декодировании
    func importFromFile(url: URL, merge: Bool = false) throws {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let export = try decoder.decode(BlacklistExport.self, from: data)
        
        if merge {
            // Добавляем только уникальные правила (по паттерну)
            let existingPatterns = Set(rules.map { $0.pattern })
            let newRules = export.rules.filter { !existingPatterns.contains($0.pattern) }
            rules.append(contentsOf: newRules)
        } else {
            rules = export.rules
        }
        save()
    }
    
    // MARK: - Statistics
    
    /// Получить количество активных правил
    var activeRulesCount: Int {
        rules.filter { $0.isEnabled }.count
    }
    
    /// Получить количество всех правил
    var totalRulesCount: Int {
        rules.count
    }
    
    // MARK: - Private
    
    /// Сохранить правила в хранилище
    private func save() {
        storage.save(rules)
    }
}

// MARK: - Export Model

/// Модель для экспорта/импорта правил
struct BlacklistExport: Codable {
    let version: String
    let rules: [BlacklistRule]
}