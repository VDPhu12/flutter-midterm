import '../models/lecturer.dart';

/// Abstract repository for the GiangVien collection.
/// Swap implementations (Firestore, in-memory for tests) without touching screens.
abstract class LecturerRepository {
  /// Real-time stream of all lecturers (ordered by IDGV).
  Stream<List<Lecturer>> watchAll();

  /// Returns all lecturers once (for export, dashboard).
  Future<List<Lecturer>> getAll();

  /// Adds a new lecturer. Uses IDGV as the document ID.
  /// Throws [StateError] if a document with that IDGV already exists.
  Future<void> add(Lecturer lecturer);

  /// Overwrites the lecturer document identified by [idGV].
  /// IDGV is immutable: the document ID must match lecturer.idGV.
  Future<void> update(Lecturer lecturer);

  /// Deletes the lecturer document with [idGV].
  Future<void> delete(String idGV);

  /// Returns true if a document with [idGV] already exists.
  Future<bool> exists(String idGV);
}
