import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/image_service.dart';
import '../data/lecturer_repository.dart';
import '../models/lecturer.dart';
import '../widgets/lecturer_avatar.dart';

/// Add / Edit form for a Lecturer.
/// Returns the saved [Lecturer] when popped, or null on cancel.
class LecturerFormScreen extends StatefulWidget {
  const LecturerFormScreen({
    super.key,
    required this.repository,
    required this.imageService,
    this.lecturer,
  });

  final LecturerRepository repository;
  final ImageService imageService;

  /// Null → add mode. Non-null → edit mode.
  final Lecturer? lecturer;

  @override
  State<LecturerFormScreen> createState() => _LecturerFormScreenState();
}

class _LecturerFormScreenState extends State<LecturerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _idCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _sumClassCtrl;

  bool _saving = false;
  bool _pickingImage = false;
  String? _saveError;

  bool get _isEditing => widget.lecturer != null;

  @override
  void initState() {
    super.initState();
    _idCtrl = TextEditingController(text: widget.lecturer?.idGV ?? '');
    _nameCtrl = TextEditingController(text: widget.lecturer?.fullname ?? '');
    _imageCtrl = TextEditingController(text: widget.lecturer?.image ?? '');
    _sumClassCtrl = TextEditingController(
      text: widget.lecturer?.sumClass.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    _imageCtrl.dispose();
    _sumClassCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Image picking
  // ---------------------------------------------------------------------------

  Future<void> _pickImage() async {
    setState(() => _pickingImage = true);
    try {
      final result = await widget.imageService.pickImage();
      if (result != null) {
        setState(() => _imageCtrl.text = result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });

    final lecturer = Lecturer(
      idGV: _idCtrl.text.trim(),
      fullname: _nameCtrl.text.trim(),
      image: _imageCtrl.text.trim(),
      sumClass: int.tryParse(_sumClassCtrl.text.trim()) ?? 0,
    );

    try {
      if (_isEditing) {
        await widget.repository.update(lecturer);
      } else {
        await widget.repository.add(lecturer);
      }
      if (mounted) Navigator.pop(context, lecturer);
    } on StateError catch (e) {
      setState(() => _saveError = e.message);
    } catch (e) {
      setState(() => _saveError = 'Lỗi lưu dữ liệu: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final imageVal = _imageCtrl.text;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa giảng viên' : 'Thêm giảng viên'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // --- IDGV ---
            TextFormField(
              key: const Key('idGVField'),
              controller: _idCtrl,
              enabled: !_isEditing, // immutable after creation
              decoration: InputDecoration(
                labelText: 'Mã giảng viên (IDGV) *',
                hintText: 'VD: GV001',
                helperText: _isEditing ? 'Không thể thay đổi IDGV.' : null,
                filled: _isEditing,
                fillColor: _isEditing ? const Color(0xFFF0F0F0) : null,
              ),
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'IDGV là bắt buộc.';
                if (v.trim().length < 2) return 'IDGV tối thiểu 2 ký tự.';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- Fullname ---
            TextFormField(
              key: const Key('fullnameField'),
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Họ và tên *',
                hintText: 'VD: Nguyễn Văn A',
              ),
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Họ và tên là bắt buộc.';
                }
                if (v.trim().length < 2) {
                  return 'Họ và tên tối thiểu 2 ký tự.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- SumClass ---
            TextFormField(
              key: const Key('sumClassField'),
              controller: _sumClassCtrl,
              decoration: const InputDecoration(
                labelText: 'Số lớp đang dạy *',
                hintText: '0',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.next,
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null) return 'Vui lòng nhập số nguyên.';
                if (n < 0) return 'Số lớp không được âm.';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- Image ---
            TextFormField(
              key: const Key('imageField'),
              controller: _imageCtrl,
              decoration: InputDecoration(
                labelText: 'Ảnh (URL hoặc chọn từ thiết bị)',
                hintText: 'https://... hoặc dùng nút bên dưới',
                suffixIcon: _imageCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        tooltip: 'Xóa ảnh',
                        onPressed: () {
                          _imageCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 10),

            // Pick image button
            OutlinedButton.icon(
              onPressed: _pickingImage ? null : _pickImage,
              icon: _pickingImage
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.photo_library_outlined),
              label: Text(
                _pickingImage ? 'Đang xử lý...' : 'Chọn ảnh từ thiết bị',
              ),
            ),
            const SizedBox(height: 12),

            // Image preview
            if (imageVal.isNotEmpty) ...[
              const Text(
                'Xem trước ảnh:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Center(
                child: LecturerAvatar(
                  imageValue: imageVal,
                  size: 120,
                  borderRadius: 10,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Error banner
            if (_saveError != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEECEC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE53E3E)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFE53E3E),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _saveError!,
                        style: const TextStyle(
                          color: Color(0xFFE53E3E),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    key: const Key('saveButton'),
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isEditing ? 'Lưu thay đổi' : 'Thêm giảng viên'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
