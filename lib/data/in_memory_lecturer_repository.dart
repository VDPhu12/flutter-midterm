import '../models/lecturer.dart';
import 'lecturer_repository.dart';

/// In-memory implementation of [LecturerRepository] — used in unit tests only.
/// Not used in production; never touches Firebase.
class InMemoryLecturerRepository implements LecturerRepository {
  InMemoryLecturerRepository([List<Lecturer>? seed]) {
    if (seed != null) {
      for (final l in seed) {
        _store[l.idGV] = l;
      }
    }
  }

  final Map<String, Lecturer> _store = {};

  List<Lecturer> _sorted() =>
      _store.values.toList()..sort((a, b) => a.idGV.compareTo(b.idGV));

  @override
  Stream<List<Lecturer>> watchAll() async* {
    yield _sorted();
  }

  @override
  Future<List<Lecturer>> getAll() async => _sorted();

  @override
  Future<bool> exists(String idGV) async => _store.containsKey(idGV);

  @override
  Future<void> add(Lecturer lecturer) async {
    if (_store.containsKey(lecturer.idGV)) {
      throw StateError('Giảng viên với IDGV "${lecturer.idGV}" đã tồn tại.');
    }
    _store[lecturer.idGV] = lecturer;
  }

  @override
  Future<void> update(Lecturer lecturer) async {
    if (!_store.containsKey(lecturer.idGV)) {
      throw StateError('Không tìm thấy giảng viên "${lecturer.idGV}".');
    }
    _store[lecturer.idGV] = lecturer;
  }

  @override
  Future<void> delete(String idGV) async {
    if (!_store.containsKey(idGV)) {
      throw StateError('Không tìm thấy giảng viên "$idGV".');
    }
    _store.remove(idGV);
  }
}
