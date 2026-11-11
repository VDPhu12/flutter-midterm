import 'package:flutter/foundation.dart';

/// A generic item that can represent products, students, tasks, books, etc.
/// Rename fields (or subclass) when adapting this to your actual assignment.
@immutable
class Item {
  const Item({
    required this.id,
    required this.title,
    this.description = '',
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  /// Creates a copy with updated fields; omit a field to keep the original.
  Item copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^ title.hashCode ^ description.hashCode ^ createdAt.hashCode;

  @override
  String toString() => 'Item(id: $id, title: $title, createdAt: $createdAt)';
}
