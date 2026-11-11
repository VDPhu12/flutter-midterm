import 'package:flutter_test/flutter_test.dart';
import 'package:midterm_ready/data/in_memory_item_repository.dart';
import 'package:midterm_ready/models/item.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Repository unit tests
  // ---------------------------------------------------------------------------
  group('InMemoryItemRepository', () {
    late InMemoryItemRepository repo;

    setUp(() => repo = InMemoryItemRepository());

    test('seeds 5 items on construction', () {
      expect(repo.getAll().length, 5);
    });

    test('add() inserts a new item with a generated id', () {
      final before = repo.getAll().length;
      final draft = Item(
        id: '',
        title: 'New Item',
        description: 'Test',
        createdAt: DateTime.now(),
      );
      final saved = repo.add(draft);

      expect(repo.getAll().length, before + 1);
      expect(saved.id, isNotEmpty);
      expect(saved.title, 'New Item');
    });

    test('update() replaces an existing item', () {
      final original = repo.getAll().first;
      final updated = original.copyWith(title: 'Updated Title');
      repo.update(updated);

      final fetched = repo.getById(original.id);
      expect(fetched?.title, 'Updated Title');
    });

    test('update() throws StateError for unknown id', () {
      final ghost = Item(
        id: 'nonexistent',
        title: 'Ghost',
        description: '',
        createdAt: DateTime.now(),
      );
      expect(() => repo.update(ghost), throwsStateError);
    });

    test('delete() removes the item', () {
      final target = repo.getAll().first;
      final before = repo.getAll().length;
      repo.delete(target.id);

      expect(repo.getAll().length, before - 1);
      expect(repo.getById(target.id), isNull);
    });

    test('delete() throws StateError for unknown id', () {
      expect(() => repo.delete('nonexistent'), throwsStateError);
    });

    test('search() filters by title (case-insensitive)', () {
      repo.add(
        Item(
          id: '',
          title: 'Kotlin Coroutines',
          description: '',
          createdAt: DateTime.now(),
        ),
      );
      final results = repo.search('kotlin');
      expect(results.length, 1);
      expect(results.first.title, 'Kotlin Coroutines');
    });

    test('search() filters by description', () {
      final results = repo.search('null safety');
      expect(results.isNotEmpty, true);
      expect(
        results.every(
          (item) =>
              item.title.toLowerCase().contains('null safety') ||
              item.description.toLowerCase().contains('null safety'),
        ),
        true,
      );
    });

    test('search() with empty string returns all items', () {
      expect(repo.search('').length, repo.getAll().length);
    });

    test('getById() returns null for missing id', () {
      expect(repo.getById('nope'), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Item model unit tests
  // ---------------------------------------------------------------------------
  group('Item model', () {
    final base = Item(
      id: '1',
      title: 'Base',
      description: 'Desc',
      createdAt: DateTime(2024, 1, 1),
    );

    test('copyWith() updates specified fields only', () {
      final copy = base.copyWith(title: 'Modified');
      expect(copy.title, 'Modified');
      expect(copy.description, base.description);
      expect(copy.createdAt, base.createdAt);
    });

    test('equality holds for identical fields', () {
      final a = Item(
        id: '1',
        title: 'Base',
        description: 'Desc',
        createdAt: DateTime(2024, 1, 1),
      );
      expect(a, equals(base));
    });

    test('equality fails when id differs', () {
      final b = base.copyWith(id: '2');
      expect(b, isNot(equals(base)));
    });
  });
}
