# MIDTERM GUIDE — Adapting the Starter to Any Assignment

This guide walks through the most common adaptation tasks you will face in a midterm.

---

## 1. Rename the Domain (Item → Product / Student / Task / Book)

The starter uses a generic `Item` model. Renaming takes about 10 minutes.

### Step A — Rename the model file

```dart
// lib/models/product.dart
@immutable
class Product {
  const Product({
    required this.id,
    required this.title,       // keep — used everywhere as the display name
    this.description = '',
    required this.createdAt,
    // Add your new fields here ↓
    required this.price,
    required this.category,
  });

  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final double price;
  final String category;

  Product copyWith({ ... }) { ... }
}
```

### Step B — Update the repository interface

```dart
// lib/data/product_repository.dart
abstract class ProductRepository {
  List<Product> getAll();
  List<Product> search(String query);
  Product? getById(String id);
  Product add(Product product);
  Product update(Product product);
  void delete(String id);
}
```

### Step C — Update the in-memory implementation

Replace `Item` with `Product` in `in_memory_item_repository.dart` and update the seed data to reflect your domain.

### Step D — Update screens and widgets

Perform a project-wide **Find & Replace**:
- `Item` → `Product` (or `Student`, `Task`, `Book`)
- `item` → `product`
- `"Item"` → `"Product"` (string labels in AppBar titles etc.)

In VS Code: `Ctrl+Shift+H` → check **Match Case** → Replace in Files.

### Step E — Wire it up in `app.dart`

```dart
class MidtermApp extends StatelessWidget {
  MidtermApp({super.key}) : _repository = InMemoryProductRepository();

  final InMemoryProductRepository _repository;
  ...
}
```

---

## 2. Add Fields to the Form

### A — Add a field to the model

```dart
class Product {
  ...
  final double price;      // ← new field

  const Product({ ..., required this.price });

  Product copyWith({ ..., double? price }) => Product(
    ...
    price: price ?? this.price,
  );
}
```

### B — Add a controller and validator to `ItemFormScreen`

```dart
// In _ItemFormScreenState
late final TextEditingController _priceController;

@override
void initState() {
  super.initState();
  _priceController = TextEditingController(
    text: widget.item?.price.toString() ?? '',
  );
}

@override
void dispose() {
  _priceController.dispose();
  super.dispose();
}
```

### C — Add the form field in `build()`

```dart
TextFormField(
  controller: _priceController,
  decoration: const InputDecoration(labelText: 'Price *'),
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  validator: (value) {
    final parsed = double.tryParse(value ?? '');
    if (parsed == null || parsed < 0) return 'Enter a valid price.';
    return null;
  },
),
```

### D — Use it in `_save()`

```dart
final draft = Product(
  id: '',
  title: _titleController.text.trim(),
  price: double.parse(_priceController.text.trim()),
  ...
);
```

---

## 3. Add Validation Rules

All validation lives in the `validator` callback of each `TextFormField`.

```dart
validator: (value) {
  if (value == null || value.trim().isEmpty) return 'Required.';
  if (value.trim().length > 100) return 'Max 100 characters.';
  final number = int.tryParse(value.trim());
  if (number == null) return 'Must be a number.';
  if (number < 0 || number > 150) return 'Age must be between 0 and 150.';
  return null; // valid
},
```

The form checks every validator when the user taps **Save**, so you can add as many as needed.

---

## 4. Change the Theme

Everything lives in `lib/app/theme.dart`. Change just the seed color and the whole app re-themes:

```dart
static const Color seedColor = Color(0xFF388E3C); // green-700
```

You can also change `brightness`, `typography`, shape radii, and more. See [Material Theme Builder](https://m3.material.io/theme-builder) for inspiration.

---

## 5. Replace In-Memory Storage with Firebase Firestore

If the actual assignment requires a real backend:

### Step A — Add the dependency

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^3.x.x
  cloud_firestore: ^5.x.x
```

```bash
flutter pub get
flutterfire configure   # connects your app to a Firebase project
```

### Step B — Create a Firestore repository

```dart
// lib/data/firestore_item_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';
import 'item_repository.dart';

class FirestoreItemRepository implements ItemRepository {
  final _col = FirebaseFirestore.instance.collection('items');

  @override
  Future<List<Item>> getAll() async {
    final snap = await _col.orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => _fromDoc(d)).toList();
  }

  @override
  Future<Item> add(Item item) async {
    final ref = await _col.add(_toMap(item));
    return item.copyWith(id: ref.id);
  }

  // ... implement update(), delete(), getById(), search()

  Item _fromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Item(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> _toMap(Item item) => {
    'title': item.title,
    'description': item.description,
    'createdAt': Timestamp.fromDate(item.createdAt),
  };
}
```

> **Note:** Firestore methods are async. The screen code will need `async/await` and `FutureBuilder` or a `setState` after `await repo.getAll()`.

### Step C — Swap in `app.dart`

```dart
// lib/app/app.dart
class MidtermApp extends StatelessWidget {
  MidtermApp({super.key}) : _repository = FirestoreItemRepository();
  ...
}
```

No screen or widget code changes needed — the repository interface is the same.

---

## 6. Replace In-Memory Storage with SQLite

```yaml
# pubspec.yaml
dependencies:
  sqflite: ^2.x.x
  path: ^1.x.x
```

Create `SqliteItemRepository implements ItemRepository` with SQL `INSERT`, `UPDATE`, `DELETE`, `SELECT`. The swap in `app.dart` is identical to the Firebase step above.

---

## 7. Quick Reference Card

| Task | File to edit |
|---|---|
| Change seed color / font | `lib/app/theme.dart` |
| Rename domain entity | `lib/models/item.dart` + rename file |
| Change seed data | `lib/data/in_memory_item_repository.dart` |
| Add a form field | `lib/screens/item_form_screen.dart` |
| Add validation | `lib/screens/item_form_screen.dart` → `validator:` |
| Show extra data in list | `lib/widgets/item_card.dart` |
| Show extra data in detail | `lib/screens/item_detail_screen.dart` |
| Swap backend | `lib/data/` + `lib/app/app.dart` |
| Root app config | `lib/app/app.dart` |

---

## 8. Checklist Before Submitting Your Midterm

- [ ] Seed data matches your assignment domain
- [ ] All required fields are present in the model
- [ ] Form validates all required fields
- [ ] Add, Edit, Delete all work end-to-end
- [ ] SnackBar feedback is shown for each action
- [ ] Empty state is visible when list is empty
- [ ] `flutter analyze` returns 0 issues
- [ ] `flutter test` passes
- [ ] App builds and runs on Android emulator
