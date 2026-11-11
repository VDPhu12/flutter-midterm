# Midterm Ready — Flutter Starter

A clean, minimal Flutter starter built with **Material 3** and **zero external dependencies** (beyond the Flutter SDK itself). Built as a reusable scaffold for a university cross-platform mobile development midterm.

---

## Project Structure

```
lib/
├── main.dart                     ← Entry point
├── app/
│   ├── app.dart                  ← Root MaterialApp + repository wiring
│   └── theme.dart                ← Material 3 light/dark themes
├── models/
│   └── item.dart                 ← Generic Item model (id, title, description, createdAt)
├── data/
│   ├── item_repository.dart      ← Abstract repository interface
│   └── in_memory_item_repository.dart  ← In-memory impl with 5 seed items
├── screens/
│   ├── item_list_screen.dart     ← List + search + empty state + FAB
│   ├── item_form_screen.dart     ← Add / Edit form with validation
│   └── item_detail_screen.dart   ← Read-only detail view
└── widgets/
    └── item_card.dart            ← Reusable card for list items

test/
├── repository_test.dart          ← Unit tests for repository + model
└── widget_test.dart              ← Widget tests for app smoke + form validation
```

---

## How to Run

### Prerequisites
- Flutter 3.x stable (tested with 3.47.9)
- An Android emulator or physical device connected, **or** run on Windows desktop

### Commands

```bash
# Get dependencies (already resolved — only flutter SDK itself)
flutter pub get

# Run on a connected device or emulator
flutter run

# Run all tests
flutter test --reporter=expanded

# Analyze for lint issues
flutter analyze

# Build a debug APK for Android
flutter build apk --debug
```

---

## Features

| Feature | Status |
|---|---|
| Item list with 5 seeded items | ✅ |
| Search (title + description, case-insensitive) | ✅ |
| Empty state with helpful message | ✅ |
| Add item (form + validation) | ✅ |
| Edit item | ✅ |
| Delete item with confirmation dialog | ✅ |
| SnackBar feedback on add / edit / delete | ✅ |
| Item detail screen | ✅ |
| Material 3 light + dark theme | ✅ |
| No Firebase / no external packages | ✅ |

---

## Dependencies

| Package | Purpose |
|---|---|
| `flutter` SDK | Everything — UI, Material 3 |
| `cupertino_icons` | iOS-style icons (bundled by default) |
| `flutter_test` | Testing framework |
| `flutter_lints` | Recommended lint rules |

No `provider`, no `riverpod`, no `get_it`, no Firebase. Pure Flutter.

---

## Architecture

```
main.dart
  └── MidtermApp (app.dart)
        └── InMemoryItemRepository (injected via constructor)
              └── ItemListScreen
                    ├── ItemCard (widget)
                    ├── ItemFormScreen (push)
                    └── ItemDetailScreen (push)
                          └── ItemFormScreen (push from detail)
```

The repository is passed down through constructors — simple, explicit, and easy to understand. When the assignment requires Firebase or SQLite, you only change `app.dart` to swap the repository implementation.

---

## Adapting to Your Assignment

See **MIDTERM_GUIDE.md** for step-by-step instructions on renaming the domain (products, students, tasks, books) and swapping the backend.
