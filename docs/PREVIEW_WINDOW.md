# Preview Window

## Обзор

Preview Window - это окно предпросмотра истории буфера обмена в ClipStack. Оно предоставляет удобный интерфейс для просмотра, поиска, фильтрации и управления элементами в буфере обмена.

## Архитектура

### Компоненты

1. **PreviewWindowController** - контроллер окна (AppKit)
2. **PreviewView** - основной SwiftUI view
3. **ClipItemRowView** - компонент для отображения одного элемента

### Структура

```
PreviewWindowController (NSWindowController)
    └── PreviewView (SwiftUI)
        ├── Header (заголовок и статистика)
        ├── Search & Filter Bar (поиск и фильтры)
        └── Items List (список элементов)
            └── ClipItemRowView (элемент списка)
```

## Функциональность

### 1. Просмотр истории

- **Список элементов**: Отображение всех элементов в буфере
- **Обратный порядок**: Новые элементы показываются первыми
- **Информация об элементе**:
  - Превью содержимого (первые 50 символов)
  - Тип контента (Text, URL, Code, Email)
  - Время добавления (относительное)
  - Источник (приложение, из которого скопировано)

### 2. Поиск

- **Поле поиска**: Поиск по содержимому элементов
- **Регистронезависимый**: Поиск не зависит от регистра
- **Очистка**: Кнопка для быстрой очистки поискового запроса

### 3. Фильтрация

Фильтрация по типу контента:
- **All Types** - показать все элементы
- **Text** - только текстовые элементы
- **URL** - только ссылки
- **Code** - только код
- **Email** - только email адреса

### 4. Действия с элементами

#### Копирование
- **Кнопка**: Иконка "doc.on.doc"
- **Действие**: Копирует элемент обратно в буфер обмена и вставляет
- **Уведомление**: "Copied to Clipboard"

#### Удаление
- **Кнопка**: Иконка "trash" (красная)
- **Действие**: Удаляет элемент из истории
- **Уведомление**: "Item Deleted"

#### Очистка всего
- **Кнопка**: "Clear All" в заголовке
- **Действие**: Удаляет все элементы из буфера
- **Уведомление**: "History Cleared"

### 5. Интерактивность

- **Hover эффект**: При наведении на элемент появляются кнопки действий
- **Анимации**: Плавные переходы при наведении
- **Пустое состояние**: Информативное сообщение когда нет элементов

## Использование

### Открытие окна

Окно можно открыть несколькими способами:

1. **Горячая клавиша**: `⌘⇧C` (Cmd+Shift+C)
2. **Menu Bar**: Клик на иконку в menu bar (будет добавлено)

### Навигация

- **Прокрутка**: Используйте колесо мыши или трекпад
- **Поиск**: Начните вводить в поле поиска
- **Фильтр**: Выберите тип контента из меню

### Работа с элементами

1. **Копировать элемент**:
   - Наведите на элемент
   - Нажмите кнопку копирования
   - Элемент будет скопирован и вставлен

2. **Удалить элемент**:
   - Наведите на элемент
   - Нажмите кнопку удаления
   - Элемент будет удалён из истории

3. **Очистить всё**:
   - Нажмите "Clear All" в заголовке
   - Все элементы будут удалены

## Технические детали

### PreviewWindowController

```swift
final class PreviewWindowController: NSWindowController {
    private let clipBuffer: ClipBuffer
    private let clipboardMonitor: ClipboardMonitor
    
    // Callbacks
    var onCopyItem: ((ClipItem) -> Void)?
    var onDeleteItem: ((ClipItem) -> Void)?
    var onClearAll: (() -> Void)?
    
    func show()    // Показать окно
    func hide()    // Скрыть окно
    func toggle()  // Переключить видимость
}
```

### PreviewView

```swift
struct PreviewView: View {
    @ObservedObject var clipBuffer: ClipBuffer
    
    @State private var searchText = ""
    @State private var selectedContentType: ClipItem.ContentType?
    
    var onCopyItem: (ClipItem) -> Void
    var onDeleteItem: (ClipItem) -> Void
    var onClearAll: () -> Void
}
```

### ClipItemRowView

```swift
struct ClipItemRowView: View {
    let item: ClipItem
    let onCopy: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovered = false
}
```

## Интеграция с AppDelegate

```swift
class AppDelegate: NSObject, NSApplicationDelegate {
    private lazy var previewWindowController: PreviewWindowController = {
        let controller = PreviewWindowController(
            clipBuffer: self.clipBuffer,
            clipboardMonitor: self.clipboardMonitor
        )
        controller.onCopyItem = { [weak self] item in
            self?.updateMenuBarBadge()
        }
        controller.onDeleteItem = { [weak self] item in
            self?.updateMenuBarBadge()
        }
        controller.onClearAll = { [weak self] in
            self?.updateMenuBarBadge()
        }
        return controller
    }()
    
    private func handleShowBuffer() {
        previewWindowController.show()
    }
}
```

## UI/UX особенности

### Дизайн

- **Минималистичный**: Чистый и простой интерфейс
- **Нативный**: Использует стандартные macOS компоненты
- **Адаптивный**: Окно можно изменять в размере

### Размеры окна

- **Минимальный размер**: 600x400 пикселей
- **Начальный размер**: 700x500 пикселей
- **Позиция**: Центр экрана при первом открытии
- **Сохранение**: Позиция и размер сохраняются автоматически

### Цветовая схема

- **Акцентный цвет**: Системный акцентный цвет
- **Hover эффект**: Серый с прозрачностью 0.1
- **Иконки**: Системные SF Symbols
- **Текст**: Стандартные цвета (primary, secondary)

## Горячие клавиши

| Действие | Комбинация | Описание |
|----------|------------|----------|
| Открыть окно | `⌘⇧C` | Показать Preview Window |
| Закрыть окно | `⌘W` | Закрыть окно (стандартная) |
| Поиск | `⌘F` | Фокус на поле поиска (будет добавлено) |

## Уведомления

Preview Window показывает уведомления для следующих действий:

1. **Copied to Clipboard**
   - Когда элемент скопирован
   - Показывает превью элемента

2. **Item Deleted**
   - Когда элемент удалён
   - Подтверждение удаления

3. **History Cleared**
   - Когда вся история очищена
   - Показывает количество удалённых элементов

## Производительность

### Оптимизации

- **LazyVStack**: Ленивая загрузка элементов списка
- **Фильтрация**: Эффективная фильтрация на уровне данных
- **Анимации**: Оптимизированные SwiftUI анимации

### Ограничения

- **Максимум элементов**: 100 (настраивается в ClipBuffer)
- **Превью**: Только первые 50 символов
- **Прокрутка**: Виртуализированный список

## Будущие улучшения

### Планируемые функции

1. **Закрепление элементов** (Pin)
   - Возможность закрепить важные элементы
   - Закреплённые элементы всегда сверху

2. **Экспорт/Импорт**
   - Экспорт истории в файл
   - Импорт из файла

3. **Группировка**
   - Группировка по дате
   - Группировка по приложению

4. **Расширенный поиск**
   - Поиск по регулярным выражениям
   - Поиск по дате

5. **Контекстное меню**
   - Правый клик на элементе
   - Дополнительные действия

6. **Drag & Drop**
   - Перетаскивание элементов
   - Изменение порядка

## Отладка

### Логирование

```swift
// В PreviewWindowController
private func handleCopyItem(_ item: ClipItem) {
    print("Copying item: \(item.preview)")
    // ...
}

private func handleDeleteItem(_ item: ClipItem) {
    print("Deleting item: \(item.id)")
    // ...
}
```

### Проверка состояния

```swift
// Проверить количество элементов
print("Buffer count: \(clipBuffer.count)")

// Проверить фильтрацию
print("Filtered items: \(filteredItems.count)")

// Проверить поиск
print("Search text: \(searchText)")
```

## Известные проблемы

### SwiftUI Preview

**Проблема**: `#Preview` макрос не работает в SPM проектах

**Решение**: Удалён из кода, используйте запуск приложения для тестирования

### Производительность с большим количеством элементов

**Проблема**: Может быть медленно с 100+ элементами

**Решение**: Используется LazyVStack для ленивой загрузки

## Ссылки

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [NSWindowController](https://developer.apple.com/documentation/appkit/nswindowcontroller)
- [NSHostingView](https://developer.apple.com/documentation/swiftui/nshostingview)