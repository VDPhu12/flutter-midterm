import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/lecturer.dart';
import 'lecturer_repository.dart';

/// Firestore-backed implementation of [LecturerRepository].
///
/// Collection: `GiangVien`
/// Document ID: the lecturer's IDGV value.
/// Fields: exactly IDGV, Fullname, Image, SumClass — nothing else.
class FirestoreLecturerRepository implements LecturerRepository {
  FirestoreLecturerRepository()
    : _col = FirebaseFirestore.instance.collection('GiangVien');

  final CollectionReference<Map<String, dynamic>> _col;

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  @override
  Stream<List<Lecturer>> watchAll() {
    return _col.orderBy('IDGV').snapshots().map((snap) {
      return snap.docs
          .map((doc) => Lecturer.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<List<Lecturer>> getAll() async {
    final snap = await _col.orderBy('IDGV').get();
    return snap.docs
        .map((doc) => Lecturer.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<bool> exists(String idGV) async {
    final doc = await _col.doc(idGV).get();
    return doc.exists;
  }

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  @override
  Future<void> add(Lecturer lecturer) async {
    final docRef = _col.doc(lecturer.idGV);

    // Safe duplicate prevention: use a transaction to check-then-write atomically.
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (snap.exists) {
        throw StateError('Giảng viên với IDGV "${lecturer.idGV}" đã tồn tại.');
      }
      tx.set(docRef, lecturer.toFirestore());
    });
  }

  @override
  Future<void> update(Lecturer lecturer) async {
    // set() with merge:false replaces the entire document — prevents extra fields.
    await _col.doc(lecturer.idGV).set(lecturer.toFirestore());
  }

  @override
  Future<void> delete(String idGV) async {
    await _col.doc(idGV).delete();
  }
}
