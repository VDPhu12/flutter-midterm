import '../models/item.dart';

/// Abstract repository interface.
/// Swap the implementation (e.g., FirestoreItemRepository) without touching
/// any screen or widget code.
abstract class ItemRepository {
  /// Returns all items, unfiltered.
  List<Item> getAll();

  /// Returns items whose title or description contains [query] (case-insensitive).
  List<Item> search(String query);

  /// Returns the item with [id], or null if not found.
  Item? getById(String id);

  /// Adds [item] to the store and returns it.
  Item add(Item item);

  /// Replaces the existing item that has the same id as [item].
  /// Throws [StateError] if no item with that id exists.
  Item update(Item item);

  /// Removes the item with [id].
  /// Throws [StateError] if no item with that id exists.
  void delete(String id);
}
