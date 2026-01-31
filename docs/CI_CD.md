# CI/CD Pipeline

## Обзор

ClipStack использует GitHub Actions для автоматизации процессов сборки, тестирования и проверки качества кода.

## Workflow

CI pipeline запускается автоматически при:
- Push в ветки `develop` и `main`
- Создании Pull Request в ветки `develop` и `main`

## Jobs

### 1. Build and Test

**Цель**: Проверка успешной сборки проекта и запуск тестов

**Окружение**: macOS 14 с Xcode 15.2

**Шаги**:
1. Checkout кода из репозитория
2. Настройка Xcode версии 15.2
3. Кэширование Swift Package Manager зависимостей
4. Сборка проекта (`swift build -v`)
5. Запуск тестов (`swift test -v`)

**Кэширование**: 
- Кэшируется директория `.build`
- Ключ кэша: `${{ runner.os }}-spm-${{ hashFiles('**/Package.resolved') }}`

### 2. SwiftLint

**Цель**: Проверка соответствия кода стандартам Swift

**Окружение**: macOS 14

**Шаги**:
1. Checkout кода
2. Установка SwiftLint через Homebrew
3. Запуск SwiftLint в strict режиме

**Конфигурация**: Используется `.swiftlint.yml` из корня проекта

### 3. Code Quality Checks

**Цель**: Дополнительные проверки качества кода

**Окружение**: macOS 14

**Проверки**:

#### TODO Comments
- Поиск TODO комментариев в коде
- Не блокирует сборку, только предупреждает
- Помогает отслеживать незавершённые задачи

#### File Headers
- Проверка наличия заголовков в Swift файлах
- Все файлы должны начинаться с комментария `//`
- Блокирует сборку при отсутствии заголовков

#### Large Files
- Проверка размера файлов (>500 строк)
- Предупреждает о больших файлах
- Не блокирует сборку
- Помогает выявлять кандидатов на рефакторинг

## Статус Badge

В README.md добавлен badge со статусом CI:

```markdown
[![CI](https://github.com/AlexeyGvozdev/clipstack/actions/workflows/ci.yml/badge.svg)](https://github.com/AlexeyGvozdev/clipstack/actions/workflows/ci.yml)
```

## Локальная проверка

Перед push рекомендуется запустить проверки локально:

```bash
# Сборка проекта
make build

# Запуск тестов (требует Xcode)
make test

# Проверка SwiftLint
make lint

# Автоисправление SwiftLint
make lint-fix
```

## Требования

### Для успешного прохождения CI:

1. **Сборка**:
   - Проект должен собираться без ошибок
   - Все зависимости должны быть доступны

2. **Тесты**:
   - Тесты помечены как `continue-on-error: true`
   - Падение тестов не блокирует PR (пока тесты требуют Xcode)

3. **SwiftLint**:
   - Код должен соответствовать правилам `.swiftlint.yml`
   - Запускается в strict режиме (`--strict`)
   - Любые warnings считаются ошибками

4. **Заголовки файлов**:
   - Все Swift файлы должны иметь заголовок
   - Минимум - комментарий в первой строке

## Оптимизация

### Кэширование

SPM зависимости кэшируются между запусками:
- Ускоряет сборку на ~30-50%
- Кэш инвалидируется при изменении `Package.resolved`

### Параллельное выполнение

Все три job'а выполняются параллельно:
- Build and Test
- SwiftLint
- Code Quality Checks

Общее время выполнения: ~3-5 минут

## Troubleshooting

### Build Failed

**Проблема**: Сборка падает с ошибкой компиляции

**Решение**:
1. Проверить локально: `swift build`
2. Убедиться, что все файлы закоммичены
3. Проверить версию Swift/Xcode

### SwiftLint Failed

**Проблема**: SwiftLint находит нарушения

**Решение**:
1. Запустить локально: `swiftlint lint`
2. Автоисправление: `swiftlint lint --fix`
3. Проверить `.swiftlint.yml` на корректность правил

### Missing File Headers

**Проблема**: Файлы без заголовков

**Решение**:
Добавить заголовок в начало файла:
```swift
//
//  FileName.swift
//  ClipStack
//
//  Created by Author on DD.MM.YYYY.
//
```

## Будущие улучшения

### Планируется добавить:

1. **Code Coverage**:
   - Отчёты о покрытии кода тестами
   - Интеграция с Codecov

2. **Automated Releases**:
   - Автоматическое создание релизов
   - Генерация changelog
   - Подпись приложения

3. **Performance Tests**:
   - Бенчмарки производительности
   - Отслеживание регрессий

4. **Security Scanning**:
   - Проверка зависимостей на уязвимости
   - SAST анализ кода

5. **Deployment**:
   - Автоматическая публикация в App Store
   - Beta распространение через TestFlight

## Ссылки

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [SwiftLint Rules](https://realm.github.io/SwiftLint/rule-directory.html)
- [Swift Package Manager](https://swift.org/package-manager/)