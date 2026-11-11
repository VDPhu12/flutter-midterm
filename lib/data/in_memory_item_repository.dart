import '../models/item.dart';
import 'item_repository.dart';

/// In-memory implementation of [ItemRepository] with five seed items.
/// Data is lost when the app restarts — perfect for demos and tests.
/// Replace with a Firestore/SQLite implementation for production.
class InMemoryItemRepository implements ItemRepository {
  InMemoryItemRepository() {
    _items.addAll(_seedItems());
  }

  final List<Item> _items = [];
  int _counter = 0;

  // ---------------------------------------------------------------------------
  // ID generation (no extra package needed)
  // ---------------------------------------------------------------------------
  String _newId() {
    _counter++;
    return '${DateTime.now().microsecondsSinceEpoch}_$_counter';
  }

  // ---------------------------------------------------------------------------
  // Public interface
  // ---------------------------------------------------------------------------

  @override
  List<Item> getAll() => List.unmodifiable(_items);

  @override
  List<Item> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return getAll();
    return _items
        .where(
          (item) =>
              item.title.toLowerCase().contains(q) ||
              item.description.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Item? getById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Item add(Item item) {
    final newItem = item.copyWith(id: _newId());
    _items.add(newItem);
    return newItem;
  }

  @override
  Item update(Item item) {
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index == -1) {
      throw StateError('No item with id "${item.id}" found.');
    }
    _items[index] = item;
    return item;
  }

  @override
  void delete(String id) {
    final initialLength = _items.length;
    _items.removeWhere((e) => e.id == id);
    if (_items.length == initialLength) {
      throw StateError('No item with id "$id" found.');
    }
  }

  // ---------------------------------------------------------------------------
  // Seed data — adapt titles/descriptions to match your domain
  // ---------------------------------------------------------------------------
  List<Item> _seedItems() {
    final now = DateTime.now();
    return [
      Item(
        id: _newId(),
        title: 'Flutter Basics',
        description: 'Review widgets, state, and navigation fundamentals.',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Item(
        id: _newId(),
        title: 'Material 3 Design',
        description:
            'Color roles, dynamic color, and adaptive layout patterns.',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      Item(
        id: _newId(),
        title: 'State Management',
        description:
            'setState vs. InheritedWidget vs. provider — when to use each.',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Item(
        id: _newId(),
        title: 'Dart Null Safety',
        description: 'Sound null safety, late variables, and nullable types.',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Item(
        id: _newId(),
        title: 'Testing in Flutter',
        description: 'Unit tests, widget tests, and integration tests.',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
