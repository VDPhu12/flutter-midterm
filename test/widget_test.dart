import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:midterm_ready/data/image_service.dart';
import 'package:midterm_ready/data/in_memory_lecturer_repository.dart';
import 'package:midterm_ready/models/lecturer.dart';
import 'package:midterm_ready/screens/lecturer_form_screen.dart';

Lecturer _make({
  String idGV = 'GV001',
  String fullname = 'Test User',
  String image = '',
  int sumClass = 0,
}) =>
    Lecturer(idGV: idGV, fullname: fullname, image: image, sumClass: sumClass);

Widget _buildForm({Lecturer? lecturer}) {
  return MaterialApp(
    home: LecturerFormScreen(
      repository: InMemoryLecturerRepository(
        lecturer != null ? [lecturer] : null,
      ),
      imageService: ImageService(),
      lecturer: lecturer,
    ),
  );
}

void main() {
  group('LecturerFormScreen — Add mode', () {
    testWidgets('shows Vietnamese labels', (tester) async {
      await tester.pumpWidget(_buildForm());
      await tester.pumpAndSettle();
      expect(find.text('Thêm giảng viên'), findsWidgets);
      expect(find.text('IDGV là bắt buộc.'), findsNothing);
    });

    testWidgets('validates empty IDGV', (tester) async {
      await tester.pumpWidget(_buildForm());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('saveButton')));
      await tester.pumpAndSettle();
      expect(find.text('IDGV là bắt buộc.'), findsOneWidget);
    });

    testWidgets('validates empty Fullname', (tester) async {
      await tester.pumpWidget(_buildForm());
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('idGVField')), 'GV001');
      await tester.tap(find.byKey(const Key('saveButton')));
      await tester.pumpAndSettle();
      expect(find.text('Họ và tên là bắt buộc.'), findsOneWidget);
    });

    testWidgets('no validation error when both fields filled', (tester) async {
      await tester.pumpWidget(_buildForm());
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('idGVField')), 'GV001');
      await tester.enterText(
        find.byKey(const Key('fullnameField')),
        'Nguyễn Văn A',
      );
      await tester.tap(find.byKey(const Key('saveButton')));
      await tester.pumpAndSettle();
      expect(find.text('IDGV là bắt buộc.'), findsNothing);
      expect(find.text('Họ và tên là bắt buộc.'), findsNothing);
    });

    testWidgets('clears image when clear icon is pressed', (tester) async {
      await tester.pumpWidget(_buildForm());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('imageField')),
        'https://example.com/pic.jpg',
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.clear), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      final field = tester.widget<TextFormField>(
        find.byKey(const Key('imageField')),
      );
      expect(field.controller?.text, isEmpty);
    });
  });

  group('LecturerFormScreen — Edit mode', () {
    testWidgets('IDGV field is disabled in edit mode', (tester) async {
      final l = _make();
      await tester.pumpWidget(_buildForm(lecturer: l));
      await tester.pumpAndSettle();

      // The IDGV field should be disabled (read-only)
      final idField = tester.widget<TextFormField>(
        find.byKey(const Key('idGVField')),
      );
      expect(idField.enabled, isFalse);
    });

    testWidgets('pre-fills existing data', (tester) async {
      final l = _make(fullname: 'Trần Thị B', sumClass: 5);
      await tester.pumpWidget(_buildForm(lecturer: l));
      await tester.pumpAndSettle();
      expect(find.text('Trần Thị B'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });
  });
}
