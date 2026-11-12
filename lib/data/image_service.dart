import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Handles image selection and compression for the lecturer Image field.
///
/// Strategy (Spark plan — no Firebase Storage):
///   • The Image field is a plain String.
///   • On Web/Android: user picks from gallery → compressed to JPEG ≤ 80 kB →
///     stored as `data:image/jpeg;base64,<b64>` data URI in Firestore.
///   • If the user pastes a URL instead, it is stored as-is.
///   • Firestore document limit: 1 MiB. We cap at 80 kB (≈107 kB base64) to
///     stay well within budget.
///
/// Limitations (documented for the submission report):
///   • Images are stored in the lecturer document → no CDN, no sharing.
///   • Practical max image quality is roughly thumbnail-level (≤80 kB JPEG).
///   • Large existing images stored before this limit was enforced may cause
///     Firestore write failures.
class ImageService {
  static const int _maxBytes = 80 * 1024; // 80 kB compressed JPEG
  static const int _jpegQuality = 70;

  final ImagePicker _picker = ImagePicker();

  /// Picks an image from gallery/files. Returns a data-URI string on success,
  /// or null if the user cancelled.
  /// Throws a descriptive [Exception] if the compressed image is too large.
  Future<String?> pickImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: _jpegQuality,
      maxWidth: 400,
      maxHeight: 400,
    );
    if (file == null) return null;

    final bytes = await file.readAsBytes();

    if (bytes.length > _maxBytes) {
      throw Exception(
        'Ảnh sau khi nén vẫn quá lớn (${(bytes.length / 1024).toStringAsFixed(0)} kB). '
        'Vui lòng chọn ảnh nhỏ hơn hoặc dùng URL.',
      );
    }

    final b64 = base64Encode(bytes);
    return 'data:image/jpeg;base64,$b64';
  }

  /// Returns true if [value] looks like a base64 data URI we generated.
  static bool isDataUri(String value) => value.trim().startsWith('data:image/');

  /// Returns true if [value] looks like an HTTP/HTTPS URL.
  static bool isUrl(String value) {
    final v = value.trim();
    return v.startsWith('http://') || v.startsWith('https://');
  }

  /// Returns true if the string is a displayable image (data URI or URL).
  static bool isDisplayable(String value) => isDataUri(value) || isUrl(value);

  /// Decodes a data URI back to raw bytes, for display with [Image.memory].
  /// Returns null if [value] is not a valid data URI.
  static Uint8List? decodeDataUri(String value) {
    final trimmed = value.trim();
    if (!isDataUri(trimmed)) return null;
    try {
      final comma = trimmed.indexOf(',');
      if (comma == -1) return null;
      return base64Decode(trimmed.substring(comma + 1).trim());
    } catch (_) {
      return null;
    }
  }
}
