# 📋 ClipStack

> Умный менеджер буфера обмена для macOS с поддержкой режимов Stack и Queue

[![CI](https://github.com/AlexeyGvozdev/clipstack/actions/workflows/ci.yml/badge.svg)](https://github.com/AlexeyGvozdev/clipstack/actions/workflows/ci.yml)
[![macOS](https://img.shields.io/badge/macOS-12.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🎯 Что это?

ClipStack - это нативное macOS приложение, которое превращает стандартный буфер обмена в мощный инструмент для работы с множественными копированиями. Вместо того чтобы хранить только последнее скопированное значение, ClipStack накапливает все ваши копирования и позволяет извлекать их в нужном порядке.

## ✨ Ключевые особенности

- 🔄 **Два режима работы**: Stack (LIFO) и Queue (FIFO)
- ⌨️ **Горячие клавиши**: Быстрый доступ без отрыва от клавиатуры
- 🎨 **Минималистичный UI**: Иконка в menu bar с превью
- 🚫 **Чёрный список**: Фильтрация нежелательных копирований по подстрокам
- ⏱️ **Автоочистка**: Автоматическое удаление буфера по таймеру
- 🔒 **Приватность**: Все данные хранятся локально
- ⚡ **Производительность**: Нативный Swift, < 50MB памяти
- 🆓 **Open Source**: MIT лицензия

## 🚀 Быстрый старт

### Сборка и запуск

```bash
# Клонировать репозиторий
git clone https://github.com/yourusername/clipstack.git
cd clipstack

# Собрать App Bundle
chmod +x scripts/create-app-bundle.sh
./scripts/create-app-bundle.sh

# Запустить приложение
open .build/release/ClipStack.app
```

### Разработка

```bash
# Собрать проект
swift build

# Запустить тесты
swift test

# Запустить линтер
swiftlint
```

**Примечание**: Приложение требует разрешений в System Settings:
- Privacy & Security → Accessibility (для горячих клавиш)
- Privacy & Security → Automation (для Apple Events)

## ⌨️ Горячие клавиши

| Действие | Комбинация | Описание |
|----------|------------|----------|
| Извлечь первый | `Cmd+Shift+V` | Вставляет элемент из начала буфера |
| Извлечь последний | `Cmd+Shift+B` | Вставляет элемент с конца буфера |
| Переключить режим | `Cmd+Shift+M` | Stack ↔ Queue |
| Показать буфер | `Cmd+Shift+C` | Открывает окно предпросмотра |
| Очистить буфер | `Cmd+Shift+X` | Удаляет все элементы |

## 📚 Документация

Полная документация находится в папке [`docs/`](docs/):

- 📖 [Полное руководство](docs/README.md) - Детальное описание всех возможностей
- 🏗️ [Архитектура](docs/ARCHITECTURE.md) - Техническая архитектура проекта
- 📋 [План разработки](docs/DEVELOPMENT_PLAN.md) - Детальный план разработки MVP
- ⌨️ [Горячие клавиши](docs/HOTKEYS.md) - Система горячих клавиш
- 🔒 [Безопасность](docs/SECURITY.md) - Фильтрация чувствительных данных
- 🚫 [Чёрный список](docs/BLACKLIST_FEATURE.md) - Функционал фильтрации
- ⏱️ [Автоочистка](docs/AUTO_CLEAR_FEATURE.md) - Автоматическая очистка буфера
- 📱 [Menu Bar App](docs/MENU_BAR.md) - Интерфейс в строке меню
- 🪟 [Preview Window](docs/PREVIEW_WINDOW.md) - Окно предпросмотра истории
- 🚀 [Быстрый старт](docs/QUICK_START.md) - Руководство пользователя
- 📊 [Резюме проекта](docs/PROJECT_SUMMARY.md) - Краткое описание проекта
- 🗺️ [Навигация](docs/INDEX.md) - Индекс всей документации

## 🛠️ Технологический стек

- **Платформа**: macOS 12.0+
- **Язык**: Swift 5.9+
- **UI**: SwiftUI + AppKit
- **Storage**: Core Data + UserDefaults
- **APIs**: NSPasteboard, Carbon Events, UserNotifications

## 🗺️ Roadmap

### v1.0 (MVP) - Q1 2026
- [x] Базовый перехват копирования
- [x] Режимы Stack и Queue
- [x] Горячие клавиши
- [x] Фильтры безопасности
- [x] Чёрный список
- [x] Автоочистка по таймеру
- [x] Core Data хранилище
- [x] Menu bar интерфейс
- [x] Окно предпросмотра
- [ ] Окно настроек

### v1.1 - Q2 2026
- [ ] Поиск по содержимому
- [ ] Настройка горячих клавиш
- [ ] Экспорт/импорт буфера
- [ ] Статистика использования

## 🤝 Вклад в проект

Мы приветствуем любой вклад! Пожалуйста, прочитайте [CONTRIBUTING.md](CONTRIBUTING.md) перед отправкой pull request.

## 📄 Лицензия

MIT License - см. [LICENSE](LICENSE) для деталей.

## 📧 Контакты

- **GitHub**: [@yourusername](https://github.com/yourusername)
- **Email**: clipstack@example.com

---

Сделано с ❤️ для macOS разработчиков и power users