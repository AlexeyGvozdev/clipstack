//
//  BlacklistStorage.swift
//  ClipStack
//
//  Created by ClipStack on 2026-01-31.
//

import Foundation

/// Протокол для хранения правил чёрного списка
protocol BlacklistStorage {
    /// Сохранить правила
    /// - Parameter rules: Массив правил для сохранения
    func save(_ rules: [BlacklistRule])
    
    /// Загрузить правила
    /// - Returns: Массив сохранённых правил
    func load() -> [BlacklistRule]
}

/// Реализация хранилища через UserDefaults
class UserDefaultsBlacklistStorage: BlacklistStorage {
    private let key = "clipstack.blacklist.rules"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func save(_ rules: [BlacklistRule]) {
        do {
            let data = try encoder.encode(rules)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to save blacklist rules: \(error)")
        }
    }
    
    func load() -> [BlacklistRule] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }
        
        do {
            return try decoder.decode([BlacklistRule].self, from: data)
        } catch {
            print("Failed to load blacklist rules: \(error)")
            return []
        }
    }
}