# ClipStack - Навигация по документации

## 📚 Обзор проекта

**ClipStack** - умный менеджер буфера обмена для macOS с поддержкой режимов Stack и Queue, а также настраиваемым чёрным списком для фильтрации копируемых данных.

---

## 🚀 Быстрый старт

### Для пользователей
👉 **[QUICK_START.md](QUICK_START.md)** - Руководство по установке и использованию

### Для разработчиков
👉 **[DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md)** - План разработки с детальными задачами

---

## 📖 Основная документация

### 1. [README.md](README.md)
**Главная страница проекта**
- Описание проекта
- Ключевые возможности
- Установка и настройка
- Примеры использования
- Roadmap

### 2. [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)
**Краткое резюме проекта**
- Основная информация
- Проблема и решение
- Целевая аудитория
- Бизнес-модель
- Конкурентные преимущества

### 3. [PROJECT_CONCEPT.md](PROJECT_CONCEPT.md)
**Детальная концепция**
- Варианты названий
- Подробное описание функций
- Пользовательские сценарии
- UI/UX концепция
- Roadmap с деталями

---

## 🏗️ Техническая документация

### 4. [ARCHITECTURE.md](ARCHITECTURE.md)
**Техническая архитектура**
- Общая архитектура системы
- Модульная структура
- Потоки данных
- Код примеры всех модулей
- Тестирование

### 5. [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md)
**План разработки**
- 8 этапов разработки MVP
- Детальные задачи по неделям
- Структура проекта
- Стратегия тестирования
- Timeline и метрики

---

## 🎯 Специализированная документация

### 6. [HOTKEYS.md](HOTKEYS.md)
**Система горячих клавиш**
- Архитектура HotkeyManager
- Горячие клавиши по умолчанию
- Интеграция с Carbon Events API
- Обработка событий
- Требования и разрешения

### 7. [SECURITY.md](SECURITY.md)
**Security Filter - Фильтрация чувствительных данных**
- 8 типов чувствительных данных
- Автоматическая блокировка
- Интеграция с ClipboardMonitor
- Пользовательские конфигурации
- Производительность и кэширование
- Тестирование (25+ тестов)

### 8. [CI_CD.md](CI_CD.md)
**CI/CD Pipeline**
- GitHub Actions workflow
- Build and Test job
- SwiftLint проверки
- Code Quality checks
- Локальная проверка
- Troubleshooting

### 9. [BLACKLIST_FEATURE.md](BLACKLIST_FEATURE.md)
**Функционал чёрного списка**
- Назначение и примеры
- Техническая реализация
- UI/UX для управления
- Пресеты правил
- Импорт/экспорт

### 10. [AUTO_CLEAR_FEATURE.md](AUTO_CLEAR_FEATURE.md)
**Автоматическая очистка буфера**
- Назначение и примеры
- Техническая реализация
- Режимы работы
- Уведомления
- Статистика

### 11. [QUICK_START.md](QUICK_START.md)
**Руководство пользователя**
- Что такое ClipStack
- Быстрые примеры
- Установка
- Настройка
- Решение проблем

---

## 📊 Структура документации

```
clipstack/
├── INDEX.md                    ← Вы здесь
├── README.md                   ← Главная страница
├── PROJECT_SUMMARY.md          ← Краткое резюме
├── PROJECT_CONCEPT.md          ← Детальная концепция
├── ARCHITECTURE.md             ← Техническая архитектура
├── DEVELOPMENT_PLAN.md         ← План разработки
├── HOTKEYS.md                  ← Система горячих клавиш
├── SECURITY.md                 ← Security Filter
├── CI_CD.md                    ← CI/CD Pipeline
├── BLACKLIST_FEATURE.md        ← Чёрный список
├── AUTO_CLEAR_FEATURE.md       ← Автоочистка
└── QUICK_START.md              ← Руководство пользователя
```

---

## 🎯 Рекомендуемый порядок чтения

### Для новых пользователей
1. [README.md](README.md) - Общее понимание
2. [QUICK_START.md](QUICK_START.md) - Начало работы
3. [BLACKLIST_FEATURE.md](BLACKLIST_FEATURE.md) - Настройка фильтрации
4. [AUTO_CLEAR_FEATURE.md](AUTO_CLEAR_FEATURE.md) - Настройка автоочистки

### Для разработчиков
1. [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - Обзор проекта
2. [ARCHITECTURE.md](ARCHITECTURE.md) - Техническая архитектура
3. [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md) - План работ
4. [SECURITY.md](SECURITY.md) - Security Filter
5. [BLACKLIST_FEATURE.md](BLACKLIST_FEATURE.md) - Детали чёрного списка
6. [AUTO_CLEAR_FEATURE.md](AUTO_CLEAR_FEATURE.md) - Детали автоочистки

### Для инвесторов/менеджеров
1. [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - Краткое резюме
2. [PROJECT_CONCEPT.md](PROJECT_CONCEPT.md) - Детальная концепция
3. [README.md](README.md) - Roadmap и метрики

---

## 🔑 Ключевые концепции

### Режимы работы
- **Stack (LIFO)**: Последний вошёл - первый вышел
- **Queue (FIFO)**: Первый вошёл - первый вышел

### Фильтрация
- **Security Filter**: Автоматическая блокировка чувствительных данных
- **Blacklist**: Настраиваемая фильтрация по подстрокам
- **Auto-Clear**: Автоматическая очистка буфера по таймеру

### Горячие клавиши
- `Cmd+Shift+V` - Извлечь первый
- `Cmd+Shift+B` - Извлечь последний
- `Cmd+Shift+M` - Переключить режим
- `Cmd+Shift+C` - Показать буфер
- `Cmd+Shift+X` - Очистить буфер

---

## 📞 Контакты и поддержка

- **GitHub**: github.com/yourusername/clipstack
- **Email**: clipstack@example.com
- **Twitter**: @clipstack
- **Website**: clipstack.app

---

## ✅ Статус проекта

**Текущий статус**: MVP в разработке (Stage 7 - AutoClear Manager)
**Следующий шаг**: Storage Module (Stage 8)
**Версия документации**: 1.2
**Дата обновления**: 2026-01-31

---

**Приятного чтения! 📚**