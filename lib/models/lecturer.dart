import 'package:flutter/foundation.dart';

/// Represents a lecturer document in the Firestore `GiangVien` collection.
///
/// Exactly four fields — IDGV, Fullname, Image, SumClass — matching the
/// assignment schema. No extra fields are added.
@immutable
class Lecturer {
  const Lecturer({
    required this.idGV,
    required this.fullname,
    required this.image,
    required this.sumClass,
  });

  /// Unique lecturer ID. Used as the Firestore document ID.
  final String idGV;

  /// Lecturer's full name.
  final String fullname;

  /// Image URL (Phase 1) or Base64 string (Phase 2 mobile).
  final String image;

  /// Total number of classes taught. Must be non-negative.
  final int sumClass;

  // ---------------------------------------------------------------------------
  // Firestore serialization
  // ---------------------------------------------------------------------------

  /// Creates a [Lecturer] from a Firestore document snapshot map.
  factory Lecturer.fromFirestore(Map<String, dynamic> data, String docId) {
    return Lecturer(
      idGV: (data['IDGV'] as String? ?? '').trim(),
      fullname: (data['Fullname'] as String? ?? '').trim(),
      image: (data['Image'] as String? ?? '').trim(),
      sumClass: (data['SumClass'] as num? ?? 0).toInt(),
    );
  }

  /// Converts to a map for writing to Firestore.
  /// Only the four required fields are included — never extras.
  Map<String, dynamic> toFirestore() => {
    'IDGV': idGV,
    'Fullname': fullname,
    'Image': image,
    'SumClass': sumClass,
  };

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Lecturer copyWith({
    String? idGV,
    String? fullname,
    String? image,
    int? sumClass,
  }) {
    return Lecturer(
      idGV: idGV ?? this.idGV,
      fullname: fullname ?? this.fullname,
      image: image ?? this.image,
      sumClass: sumClass ?? this.sumClass,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lecturer &&
          runtimeType == other.runtimeType &&
          idGV == other.idGV &&
          fullname == other.fullname &&
          image == other.image &&
          sumClass == other.sumClass;

  @override
  int get hashCode =>
      idGV.hashCode ^ fullname.hashCode ^ image.hashCode ^ sumClass.hashCode;

  @override
  String toString() =>
      'Lecturer(idGV: $idGV, fullname: $fullname, sumClass: $sumClass)';
}
