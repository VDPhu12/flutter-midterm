import 'package:flutter_test/flutter_test.dart';
import 'package:midterm_ready/data/image_service.dart';
import 'package:midterm_ready/data/in_memory_lecturer_repository.dart';
import 'package:midterm_ready/models/lecturer.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Lecturer _make({
  String idGV = 'GV001',
  String fullname = 'Nguyễn Văn A',
  String image = '',
  int sumClass = 3,
}) =>
    Lecturer(idGV: idGV, fullname: fullname, image: image, sumClass: sumClass);

// ---------------------------------------------------------------------------

void main() {
  // ---------------------------------------------------------------------------
  // Lecturer model tests
  // ---------------------------------------------------------------------------

  group('Lecturer model', () {
    test('toFirestore() emits exactly 4 fields', () {
      final l = _make();
      final map = l.toFirestore();
      expect(map.keys.toSet(), {'IDGV', 'Fullname', 'Image', 'SumClass'});
      expect(map['IDGV'], 'GV001');
      expect(map['SumClass'], 3);
    });

    test('fromFirestore() parses correctly', () {
      final map = {
        'IDGV': 'GV002',
        'Fullname': 'Trần Thị B',
        'Image': 'https://example.com/img.jpg',
        'SumClass': 5,
      };
      final l = Lecturer.fromFirestore(map, 'GV002');
      expect(l.idGV, 'GV002');
      expect(l.fullname, 'Trần Thị B');
      expect(l.sumClass, 5);
    });

    test('fromFirestore() handles missing fields gracefully', () {
      final l = Lecturer.fromFirestore({}, 'GV003');
      expect(l.idGV, '');
      expect(l.fullname, '');
      expect(l.sumClass, 0);
    });

    test('copyWith() changes only specified fields', () {
      final a = _make();
      final b = a.copyWith(fullname: 'New Name');
      expect(b.fullname, 'New Name');
      expect(b.idGV, a.idGV);
      expect(b.sumClass, a.sumClass);
    });

    test('equality holds for identical data', () {
      expect(_make(), equals(_make()));
    });

    test('equality fails when idGV differs', () {
      expect(_make(idGV: 'GV001'), isNot(equals(_make(idGV: 'GV002'))));
    });
  });

  // ---------------------------------------------------------------------------
  // InMemoryLecturerRepository tests
  // ---------------------------------------------------------------------------

  group('InMemoryLecturerRepository', () {
    late InMemoryLecturerRepository repo;

    setUp(() {
      repo = InMemoryLecturerRepository([
        _make(idGV: 'GV001', fullname: 'Nguyễn Văn A', sumClass: 2),
        _make(idGV: 'GV002', fullname: 'Trần Thị B', sumClass: 5),
      ]);
    });

    test('getAll() returns seeded items', () async {
      final all = await repo.getAll();
      expect(all.length, 2);
    });

    test('add() stores a new lecturer', () async {
      await repo.add(_make(idGV: 'GV003', fullname: 'Lê Văn C'));
      final all = await repo.getAll();
      expect(all.length, 3);
      expect(all.any((l) => l.idGV == 'GV003'), isTrue);
    });

    test('add() throws StateError on duplicate IDGV', () async {
      expect(() => repo.add(_make(idGV: 'GV001')), throwsStateError);
    });

    test('update() replaces existing lecturer', () async {
      await repo.update(
        _make(idGV: 'GV001', fullname: 'Updated Name', sumClass: 10),
      );
      final all = await repo.getAll();
      final updated = all.firstWhere((l) => l.idGV == 'GV001');
      expect(updated.fullname, 'Updated Name');
      expect(updated.sumClass, 10);
    });

    test('update() throws StateError for unknown idGV', () async {
      expect(() => repo.update(_make(idGV: 'GV999')), throwsStateError);
    });

    test('delete() removes the lecturer', () async {
      await repo.delete('GV001');
      final all = await repo.getAll();
      expect(all.length, 1);
      expect(all.any((l) => l.idGV == 'GV001'), isFalse);
    });

    test('delete() throws StateError for unknown idGV', () async {
      expect(() => repo.delete('GV999'), throwsStateError);
    });

    test('exists() returns true for existing idGV', () async {
      expect(await repo.exists('GV001'), isTrue);
    });

    test('exists() returns false for missing idGV', () async {
      expect(await repo.exists('GV999'), isFalse);
    });

    test('watchAll() emits current list', () async {
      final list = await repo.watchAll().first;
      expect(list.length, 2);
    });

    test('getAll() sorted by IDGV', () async {
      await repo.add(_make(idGV: 'GV000', fullname: 'First'));
      final all = await repo.getAll();
      expect(all.first.idGV, 'GV000');
    });
  });

  // ---------------------------------------------------------------------------
  // Image URI helper tests (pure Dart, no engine)
  // ---------------------------------------------------------------------------

  group('Image URI helpers', () {
    test('isDataUri identifies data URIs', () {
      expect(ImageService.isDataUri('data:image/jpeg;base64,abc'), isTrue);
      expect(ImageService.isDataUri('  data:image/jpeg;base64,abc  '), isTrue);
      expect(ImageService.isDataUri('https://example.com/img.jpg'), isFalse);
      expect(ImageService.isDataUri(''), isFalse);
    });

    test('isUrl identifies http/https URLs', () {
      expect(ImageService.isUrl('https://example.com/img.jpg'), isTrue);
      expect(ImageService.isUrl('http://example.com/img.jpg'), isTrue);
      expect(ImageService.isUrl('  https://example.com/img.jpg  '), isTrue);
      expect(ImageService.isUrl('data:image/png;base64,abc'), isFalse);
    });

    test('decodeDataUri returns null for non-data-URI', () {
      expect(ImageService.decodeDataUri('https://example.com'), isNull);
      expect(ImageService.decodeDataUri(''), isNull);
    });

    test('decodeDataUri returns bytes for valid data URI', () {
      // Minimal valid base64 PNG data URI (1x1 transparent pixel)
      const uri =
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
      final bytes = ImageService.decodeDataUri(uri);
      expect(bytes, isNotNull);
      expect(bytes!.isNotEmpty, isTrue);
    });
  });
}
