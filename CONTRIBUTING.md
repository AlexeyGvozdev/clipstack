# Contributing to ClipStack

Спасибо за интерес к проекту ClipStack! Мы приветствуем любой вклад в развитие проекта.

## 🤝 Как внести вклад

### Сообщить о баге

1. Проверьте, что баг еще не был зарегистрирован в [Issues](https://github.com/AlexeyGvozdev/clipstack/issues)
2. Создайте новый Issue с подробным описанием:
   - Шаги для воспроизведения
   - Ожидаемое поведение
   - Фактическое поведение
   - Версия macOS и ClipStack
   - Скриншоты (если применимо)

### Предложить новую функцию

1. Создайте Issue с тегом `enhancement`
2. Опишите:
   - Проблему, которую решает функция
   - Предлагаемое решение
   - Альтернативные варианты
   - Примеры использования

### Отправить Pull Request

1. Fork репозитория
2. Создайте ветку для вашей функции (`git checkout -b feature/amazing-feature`)
3. Следуйте стилю кода проекта
4. Добавьте тесты для новой функциональности
5. Убедитесь, что все тесты проходят
6. Commit изменений (`git commit -m 'Add amazing feature'`)
7. Push в ветку (`git push origin feature/amazing-feature`)
8. Откройте Pull Request

## 📝 Стиль кода

### Swift Style Guide

Мы следуем [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/):

- Используйте camelCase для переменных и функций
- Используйте PascalCase для типов и протоколов
- Добавляйте документацию для публичных API
- Максимальная длина строки: 120 символов

### Пример

```swift
/// Manages clipboard buffer with Stack/Queue modes
class ClipBuffer: ClipBufferProtocol {
    // MARK: - Properties
    
    private var storage: [ClipItem] = []
    private(set) var mode: BufferMode = .stack
    
    // MARK: - Public Methods
    
    /// Adds item to buffer
    /// - Parameter item: The clip item to add
    func push(_ item: ClipItem) {
        storage.append(item)
    }
}
```

## 🧪 Тестирование

- Все новые функции должны иметь unit тесты
- Покрытие кода должно быть > 75%
- Запустите тесты перед отправкой PR: `Cmd+U` в Xcode

## 📋 Checklist для Pull Request

- [ ] Код следует стилю проекта
- [ ] Добавлены unit тесты
- [ ] Все тесты проходят
- [ ] Обновлена документация (если нужно)
- [ ] Нет SwiftLint warnings
- [ ] PR описание понятно объясняет изменения

## 🔍 Code Review Process

1. Maintainer проверит ваш PR
2. Могут быть запрошены изменения
3. После одобрения PR будет смержен
4. Ваш вклад будет отмечен в CHANGELOG

## 📞 Вопросы?

Если у вас есть вопросы, создайте [Discussion](https://github.com/AlexeyGvozdev/clipstack/discussions) или напишите на clipstack@example.com

## 📄 Лицензия

Отправляя Pull Request, вы соглашаетесь, что ваш код будет лицензирован под MIT License.

---

Спасибо за ваш вклад! 🎉