import 'package:flutter/material.dart';

import '../data/image_service.dart';

/// Displays a lecturer image from either a URL, a data URI, or a placeholder.
class LecturerAvatar extends StatelessWidget {
  const LecturerAvatar({
    super.key,
    required this.imageValue,
    this.size = 48,
    this.borderRadius = 6,
  });

  final String imageValue;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final val = imageValue.trim();

    if (val.isEmpty) {
      return _placeholder(radius);
    }

    if (ImageService.isDataUri(val)) {
      final bytes = ImageService.decodeDataUri(val);
      if (bytes == null) return _placeholder(radius);
      return ClipRRect(
        borderRadius: radius,
        child: Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => _placeholder(radius),
        ),
      );
    }

    if (ImageService.isUrl(val)) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.network(
          val,
          width: size,
          height: size,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : _loadingBox(),
          errorBuilder: (ctx, err, stack) => _placeholder(radius),
        ),
      );
    }

    return _placeholder(radius);
  }

  Widget _placeholder(BorderRadius radius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: radius,
      ),
      child: Icon(
        Icons.person_outline,
        size: size * 0.55,
        color: const Color(0xFF718096),
      ),
    );
  }

  Widget _loadingBox() {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFE2E8F0),
      child: const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
