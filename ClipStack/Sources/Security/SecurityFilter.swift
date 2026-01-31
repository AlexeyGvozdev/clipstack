//
//  SecurityFilter.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 31.01.2026.
//

import Foundation

/// Filters sensitive data from clipboard content
final class SecurityFilter {
    // MARK: - Types
    
    enum SensitivePattern: String, CaseIterable {
        case password
        case creditCard
        case apiKey
        case privateKey
        case token
        case email
        case phone
        case ssn
        
        var pattern: String {
            switch self {
            case .password:
                // Matches common password patterns
                return "(?i)(password|passwd|pwd)\\s*[:=]\\s*[\\S]+"
            case .creditCard:
                // Matches credit card numbers (with or without spaces/dashes)
                return "\\b(?:\\d[ -]*?){13,19}\\b"
            case .apiKey:
                // Matches API keys (common formats)
                return "(?i)(api[_-]?key|apikey|access[_-]?key)\\s*[:=]\\s*['\"]?[a-zA-Z0-9_\\-]{20,}['\"]?"
            case .privateKey:
                // Matches private keys (PEM format)
                return "-----BEGIN\\s+(?:RSA\\s+)?PRIVATE\\s+KEY-----"
            case .token:
                // Matches JWT tokens and bearer tokens
                return "(?i)(bearer\\s+)?[a-zA-Z0-9_\\-]+\\.[a-zA-Z0-9_\\-]+\\.[a-zA-Z0-9_\\-]+"
            case .email:
                // Matches email addresses
                return "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"
            case .phone:
                // Matches phone numbers (various formats)
                return "\\+?\\d{1,3}[\\s.-]?\\(?\\d{3}\\)?[\\s.-]?\\d{3}[\\s.-]?\\d{4}"
            case .ssn:
                // Matches US Social Security Numbers
                return "\\b\\d{3}-\\d{2}-\\d{4}\\b"
            }
        }
        
        var description: String {
            switch self {
            case .password:
                return "Password"
            case .creditCard:
                return "Credit Card Number"
            case .apiKey:
                return "API Key"
            case .privateKey:
                return "Private Key"
            case .token:
                return "Authentication Token"
            case .email:
                return "Email Address"
            case .phone:
                return "Phone Number"
            case .ssn:
                return "Social Security Number"
            }
        }
    }
    
    // MARK: - Properties
    
    private let enabledPatterns: Set<SensitivePattern>
    private var regexCache: [SensitivePattern: NSRegularExpression] = [:]
    
    // MARK: - Initialization
    
    init(enabledPatterns: Set<SensitivePattern> = Set(SensitivePattern.allCases)) {
        self.enabledPatterns = enabledPatterns
        self.regexCache = Self.buildRegexCache(for: enabledPatterns)
    }
    
    // MARK: - Public Methods
    
    /// Checks if the content contains sensitive information
    /// - Parameter content: The text content to check
    /// - Returns: Tuple with sensitivity flag and detected pattern type
    func isSensitive(_ content: String) -> (isSensitive: Bool, detectedPattern: SensitivePattern?) {
        guard !content.isEmpty else {
            return (false, nil)
        }
        
        for pattern in enabledPatterns {
            guard let regex = regexCache[pattern] else { continue }
            
            let range = NSRange(content.startIndex..., in: content)
            if regex.firstMatch(in: content, range: range) != nil {
                return (true, pattern)
            }
        }
        
        return (false, nil)
    }
    
    /// Checks if content contains any sensitive information
    /// - Parameter content: The text content to check
    /// - Returns: True if sensitive data detected
    func containsSensitiveData(_ content: String) -> Bool {
        return isSensitive(content).isSensitive
    }
    
    /// Gets all detected sensitive patterns in the content
    /// - Parameter content: The text content to check
    /// - Returns: Array of detected pattern types
    func detectAllPatterns(_ content: String) -> [SensitivePattern] {
        guard !content.isEmpty else {
            return []
        }
        
        var detected: [SensitivePattern] = []
        
        for pattern in enabledPatterns {
            guard let regex = regexCache[pattern] else { continue }
            
            let range = NSRange(content.startIndex..., in: content)
            if regex.firstMatch(in: content, range: range) != nil {
                detected.append(pattern)
            }
        }
        
        return detected
    }
    
    // MARK: - Private Methods
    
    private static func buildRegexCache(for patterns: Set<SensitivePattern>) -> [SensitivePattern: NSRegularExpression] {
        var cache: [SensitivePattern: NSRegularExpression] = [:]
        
        for pattern in patterns {
            do {
                let regex = try NSRegularExpression(
                    pattern: pattern.pattern,
                    options: [.caseInsensitive]
                )
                cache[pattern] = regex
            } catch {
                print("Failed to create regex for pattern \(pattern): \(error)")
            }
        }
        
        return cache
    }
}

// MARK: - Convenience Methods

extension SecurityFilter {
    /// Creates a filter with only critical patterns enabled
    static func criticalOnly() -> SecurityFilter {
        return SecurityFilter(enabledPatterns: [
            .password,
            .creditCard,
            .apiKey,
            .privateKey,
            .token
        ])
    }
    
    /// Creates a filter with all patterns except email and phone
    static func strictWithoutContacts() -> SecurityFilter {
        var patterns = Set(SensitivePattern.allCases)
        patterns.remove(.email)
        patterns.remove(.phone)
        return SecurityFilter(enabledPatterns: patterns)
    }
}