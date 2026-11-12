import 'package:flutter/material.dart';

import '../data/image_service.dart';
import '../data/lecturer_repository.dart';
import '../models/lecturer.dart';
import '../widgets/lecturer_avatar.dart';
import 'lecturer_form_screen.dart';

/// Read-only detail view for a single lecturer.
class LecturerDetailScreen extends StatefulWidget {
  const LecturerDetailScreen({
    super.key,
    required this.lecturer,
    required this.repository,
    required this.imageService,
  });

  final Lecturer lecturer;
  final LecturerRepository repository;
  final ImageService imageService;

  @override
  State<LecturerDetailScreen> createState() => _LecturerDetailScreenState();
}

class _LecturerDetailScreenState extends State<LecturerDetailScreen> {
  late Lecturer _lecturer;

  @override
  void initState() {
    super.initState();
    _lecturer = widget.lecturer;
  }

  Future<void> _openEdit() async {
    final updated = await Navigator.push<Lecturer>(
      context,
      MaterialPageRoute(
        builder: (_) => LecturerFormScreen(
          repository: widget.repository,
          imageService: widget.imageService,
          lecturer: _lecturer,
        ),
      ),
    );
    if (updated != null) {
      setState(() => _lecturer = updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã cập nhật "${updated.fullname}".')),
        );
      }
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa giảng viên "${_lecturer.fullname}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok != true) return;
    try {
      await widget.repository.delete(_lecturer.idGV);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa giảng viên "${_lecturer.fullname}".')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi khi xóa: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết giảng viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Chỉnh sửa',
            onPressed: _openEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Xóa',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Large avatar
                LecturerAvatar(
                  imageValue: _lecturer.image,
                  size: 120,
                  borderRadius: 16,
                ),
                const SizedBox(height: 20),

                Text(
                  _lecturer.fullname,
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2B55).withAlpha(15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _lecturer.idGV,
                    style: const TextStyle(
                      color: Color(0xFF0D2B55),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 20),

                // Info rows
                _infoRow(
                  Icons.class_outlined,
                  'Số lớp đang dạy',
                  '${_lecturer.sumClass} lớp',
                ),
                const SizedBox(height: 12),
                if (_lecturer.image.isNotEmpty)
                  _infoRow(
                    ImageService.isDataUri(_lecturer.image)
                        ? Icons.image_outlined
                        : Icons.link,
                    'Ảnh',
                    ImageService.isDataUri(_lecturer.image)
                        ? 'Ảnh đã tải lên (Base64)'
                        : _lecturer.image,
                  ),

                const SizedBox(height: 32),

                // Edit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Chỉnh sửa thông tin'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0D2B55)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF718096),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, color: Color(0xFF2D3748)),
            ),
          ],
        ),
      ],
    );
  }
}
