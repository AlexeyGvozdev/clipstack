# Security Filter

Модуль фильтрации чувствительных данных в буфере обмена.

## Обзор

SecurityFilter автоматически обнаруживает и блокирует чувствительные данные, предотвращая их попадание в буфер ClipStack. Это защищает пользователя от случайного копирования паролей, номеров кредитных карт, API ключей и другой конфиденциальной информации.

## Типы чувствительных данных

SecurityFilter распознает следующие типы данных:

### 1. Пароли (`password`)
- Строки, содержащие слова "password", "passwd", "pwd" и т.д.
- Примеры:
  ```
  password: mySecretPass123
  pwd=admin123
  ```

### 2. Номера кредитных карт (`creditCard`)
- Visa, MasterCard, American Express, Discover
- Форматы: с пробелами, дефисами или без разделителей
- Примеры:
  ```
  4532 1488 0343 6467
  5425-2334-3010-9903
  378282246310005
  ```

### 3. API ключи (`apiKey`)
- Строки, содержащие "api_key", "apikey", "api-key"
- Примеры:
  ```
  api_key: your_secret_api_key_here
  apikey=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  ```

### 4. Приватные ключи (`privateKey`)
- SSH ключи, PEM сертификаты
- Примеры:
  ```
  -----BEGIN RSA PRIVATE KEY-----
  -----BEGIN PRIVATE KEY-----
  ```

### 5. JWT токены (`jwtToken`)
- JSON Web Tokens
- Формат: три части, разделенные точками
- Пример:
  ```
  eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U
  ```

### 6. Email адреса (`email`)
- Стандартные email адреса
- Примеры:
  ```
  user@example.com
  john.doe@company.co.uk
  ```

### 7. Номера телефонов (`phoneNumber`)
- Различные форматы телефонных номеров
- Примеры:
  ```
  +7 (999) 123-45-67
  8-800-555-35-35
  +1-555-123-4567
  ```

### 8. SSN (Social Security Number) (`ssn`)
- Американские номера социального страхования
- Формат: XXX-XX-XXXX
- Пример:
  ```
  123-45-6789
  ```

## Использование

### Базовое использование

```swift
import Security

// Создание фильтра со всеми паттернами
let filter = SecurityFilter()

// Проверка содержимого
let text = "My password is: secret123"
let result = filter.isSensitive(text)

if result.isSensitive {
    print("Обнаружены чувствительные данные: \(result.detectedPattern?.rawValue ?? "unknown")")
}
```

### Пользовательская конфигурация

```swift
// Только критичные паттерны (пароли, карты, ключи)
let criticalFilter = SecurityFilter.criticalOnly()

// Строгий фильтр без контактных данных
let strictFilter = SecurityFilter.strictWithoutContacts()

// Кастомный набор паттернов
let customFilter = SecurityFilter(enabledPatterns: [.password, .apiKey, .privateKey])
```

### Детальный анализ

```swift
let text = "Email: user@example.com, Card: 4532-1488-0343-6467"
let patterns = filter.detectAllPatterns(in: text)

for pattern in patterns {
    print("Найден паттерн: \(pattern.rawValue)")
}
// Вывод:
// Найден паттерн: email
// Найден паттерн: creditCard
```

### Проверка наличия чувствительных данных

```swift
// Быстрая проверка без определения типа
if filter.containsSensitiveData(in: text) {
    print("Содержит чувствительные данные")
}
```

## Интеграция с ClipboardMonitor

SecurityFilter автоматически интегрирован с ClipboardMonitor:

```swift
class ClipboardMonitor {
    private let securityFilter: SecurityFilter
    var securityDelegate: ClipboardSecurityDelegate?
    
    func checkForChanges() {
        // Автоматическая проверка при изменении буфера
        let sensitiveCheck = securityFilter.isSensitive(string)
        if sensitiveCheck.isSensitive {
            // Блокировка элемента
            securityDelegate?.didBlockSensitiveData(pattern: sensitiveCheck.detectedPattern)
            return
        }
        // Добавление в буфер, если безопасно
    }
}
```

## Уведомления пользователя

При обнаружении чувствительных данных пользователь получает уведомление:

```swift
extension AppDelegate: ClipboardSecurityDelegate {
    func didBlockSensitiveData(pattern: SecurityFilter.SensitivePattern?) {
        let patternName = pattern?.rawValue ?? "unknown"
        showNotification(
            title: "🔒 Sensitive Data Blocked",
            body: "Detected and blocked: \(patternName)"
        )
    }
}
```

## Производительность

- **Кэширование регулярных выражений**: Все regex паттерны компилируются один раз и кэшируются
- **Ленивая инициализация**: Паттерны создаются только при первом использовании
- **Оптимизированные регулярные выражения**: Используются эффективные паттерны для быстрой проверки

## Настройка паттернов

### Добавление нового паттерна

1. Добавьте новый case в `SensitivePattern` enum:
```swift
enum SensitivePattern: String {
    case myPattern = "myPattern"
}
```

2. Добавьте regex паттерн в `patterns` dictionary:
```swift
private let patterns: [SensitivePattern: String] = [
    .myPattern: "your-regex-pattern"
]
```

3. Добавьте тесты в `SecurityFilterTests.swift`

### Изменение существующего паттерна

Отредактируйте соответствующий regex в `patterns` dictionary и обновите тесты.

## Тестирование

Модуль покрыт комплексными unit-тестами:

- ✅ 25+ тестовых случаев
- ✅ Тесты для каждого типа паттерна
- ✅ Тесты с реальными примерами данных
- ✅ Тесты множественного обнаружения
- ✅ Тесты граничных случаев
- ✅ Тесты кастомных конфигураций

Запуск тестов:
```bash
make test
# или
swift test --filter SecurityFilterTests
```

## Безопасность

### Что фильтруется
- ✅ Пароли и учетные данные
- ✅ Финансовые данные (номера карт)
- ✅ API ключи и токены
- ✅ Криптографические ключи
- ✅ Персональные данные (SSN)

### Что НЕ фильтруется по умолчанию
- ❌ Обычный текст
- ❌ URL адреса
- ❌ Код без секретов
- ❌ Email и телефоны (опционально)

### Рекомендации

1. **Используйте критичный фильтр** для максимальной безопасности:
   ```swift
   let filter = SecurityFilter.criticalOnly()
   ```

2. **Настройте под свои нужды**: Если вы часто копируете email адреса, исключите этот паттерн:
   ```swift
   let filter = SecurityFilter.strictWithoutContacts()
   ```

3. **Проверяйте логи**: Следите за уведомлениями о блокировке, чтобы понимать, какие данные фильтруются

## Ограничения

- Regex паттерны могут давать ложные срабатывания
- Не все форматы чувствительных данных могут быть распознаны
- Обфусцированные или закодированные данные могут не обнаруживаться
- Производительность зависит от размера проверяемого текста

## Будущие улучшения

- [ ] Машинное обучение для более точного обнаружения
- [ ] Поддержка дополнительных форматов данных
- [ ] Настраиваемые пользовательские паттерны через UI
- [ ] Whitelist для исключений
- [ ] Статистика обнаружений

## См. также

- [ClipboardMonitor](CLIPBOARD_MONITOR.md) - Мониторинг буфера обмена
- [Tests README](../ClipStack/Tests/README.md) - Документация по тестам
- [DEVELOPMENT_PLAN.md](../DEVELOPMENT_PLAN.md) - План разработки