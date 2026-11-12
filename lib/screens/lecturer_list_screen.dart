import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/auth_service.dart';
import '../data/image_service.dart';
import '../data/lecturer_repository.dart';
import '../models/lecturer.dart';
import '../widgets/lecturer_avatar.dart';
import 'lecturer_detail_screen.dart';
import 'lecturer_form_screen.dart';

/// Sort options for the lecturer table.
enum _SortField { idGV, fullname, sumClass }

/// Main lecturer management screen.
/// Shows a dashboard, a searchable/sortable table (web) or card list (mobile),
/// and add/edit/delete actions.
class LecturerListScreen extends StatefulWidget {
  const LecturerListScreen({
    super.key,
    required this.repository,
    required this.authService,
    required this.imageService,
    required this.user,
  });

  final LecturerRepository repository;
  final AuthService authService;
  final ImageService imageService;
  final User user;

  @override
  State<LecturerListScreen> createState() => _LecturerListScreenState();
}

class _LecturerListScreenState extends State<LecturerListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  _SortField _sortField = _SortField.idGV;
  bool _sortAsc = true;
  int? _filterMinClass;
  final _filterCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _filterCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Filter + sort
  // ---------------------------------------------------------------------------

  List<Lecturer> _applyFilters(List<Lecturer> all) {
    final q = _query.trim().toLowerCase();
    var list = q.isEmpty
        ? all
        : all.where((l) {
            return l.idGV.toLowerCase().contains(q) ||
                l.fullname.toLowerCase().contains(q);
          }).toList();

    if (_filterMinClass != null) {
      list = list.where((l) => l.sumClass >= _filterMinClass!).toList();
    }

    list.sort((a, b) {
      int cmp;
      switch (_sortField) {
        case _SortField.idGV:
          cmp = a.idGV.compareTo(b.idGV);
        case _SortField.fullname:
          cmp = a.fullname.compareTo(b.fullname);
        case _SortField.sumClass:
          cmp = a.sumClass.compareTo(b.sumClass);
      }
      return _sortAsc ? cmp : -cmp;
    });

    return list;
  }

  void _toggleSort(_SortField field) {
    setState(() {
      if (_sortField == field) {
        _sortAsc = !_sortAsc;
      } else {
        _sortField = field;
        _sortAsc = true;
      }
    });
  }

  void _sortById(int col, bool asc) => _toggleSort(_SortField.idGV);
  void _sortByName(int col, bool asc) => _toggleSort(_SortField.fullname);
  void _sortByClass(int col, bool asc) => _toggleSort(_SortField.sumClass);

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  Future<void> _openAdd() async {
    final saved = await Navigator.push<Lecturer>(
      context,
      MaterialPageRoute(
        builder: (_) => LecturerFormScreen(
          repository: widget.repository,
          imageService: widget.imageService,
        ),
      ),
    );
    if (saved != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm giảng viên "${saved.fullname}".')),
      );
    }
  }

  Future<void> _openEdit(Lecturer lecturer) async {
    final saved = await Navigator.push<Lecturer>(
      context,
      MaterialPageRoute(
        builder: (_) => LecturerFormScreen(
          repository: widget.repository,
          imageService: widget.imageService,
          lecturer: lecturer,
        ),
      ),
    );
    if (saved != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cập nhật giảng viên "${saved.fullname}".')),
      );
    }
  }

  void _openDetail(Lecturer lecturer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LecturerDetailScreen(
          lecturer: lecturer,
          repository: widget.repository,
          imageService: widget.imageService,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  Future<void> _confirmDelete(Lecturer lecturer) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa giảng viên "${lecturer.fullname}" (${lecturer.idGV})?',
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
      await widget.repository.delete(lecturer.idGV);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa giảng viên "${lecturer.fullname}".')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi khi xóa: $e')));
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Export JSON
  // ---------------------------------------------------------------------------

  Future<void> _exportJson(List<Lecturer> lecturers) async {
    final jsonStr = const JsonEncoder.withIndent('  ')
        .convert(lecturers.map((l) => l.toFirestore()).toList());

    if (kIsWeb) {
      // On Web: download via anchor element trick
      // We use a data URI with the JSON content.
      final bytes = utf8.encode(jsonStr);
      final b64 = base64Encode(bytes);
      final dataUri = 'data:application/json;base64,$b64';

      // Show the content in a dialog since we can't use dart:html directly.
      if (mounted) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xuất dữ liệu JSON'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: SelectableText(
                  jsonStr,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
        // Also trigger download via URL launcher approach
        // ignore: unused_local_variable
        final _ = dataUri; // dataUri prepared but download requires js interop
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Trên Android: sao chép JSON từ hộp thoại (tính năng lưu file sẽ có ở bản sau).',
            ),
          ),
        );
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Dữ liệu JSON'),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: SelectableText(
                  jsonStr,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  Future<void> _signOut() async {
    await widget.authService.signOut();
    // StreamBuilder in app.dart will redirect to LoginScreen automatically.
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QUẢN LÝ GIẢNG VIÊN'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: _signOut,
          ),
        ],
      ),
      body: StreamBuilder<List<Lecturer>>(
        stream: widget.repository.watchAll(),
        builder: (context, snap) {
          if (snap.hasError) {
            final err = snap.error.toString();
            return _buildError(err);
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final all = snap.data!;
          final filtered = _applyFilters(all);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dashboard
              _buildDashboard(all),
              // Toolbar
              _buildToolbar(isWide, all),
              // Table / list
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmpty()
                    : isWide
                    ? _buildTable(filtered)
                    : _buildCardList(filtered),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        icon: const Icon(Icons.add),
        label: const Text('Thêm giảng viên'),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------------------

  Widget _buildDashboard(List<Lecturer> all) {
    final total = all.length;
    final totalClasses = all.fold<int>(0, (s, l) => s + l.sumClass);

    return Container(
      color: const Color(0xFF0D2B55),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          _dashCard(Icons.people_alt_outlined, 'Tổng giảng viên', '$total'),
          const SizedBox(width: 16),
          _dashCard(Icons.class_outlined, 'Tổng số lớp', '$totalClasses'),
        ],
      ),
    );
  }

  Widget _dashCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withAlpha(40)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Toolbar (search, filter, sort, export)
  // ---------------------------------------------------------------------------

  Widget _buildToolbar(bool isWide, List<Lecturer> all) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search
          SizedBox(
            width: isWide ? 280 : double.infinity,
            height: 40,
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Tìm theo IDGV hoặc họ tên…',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: EdgeInsets.zero,
                isDense: true,
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),

          // Min class filter
          SizedBox(
            width: 150,
            height: 40,
            child: TextField(
              controller: _filterCtrl,
              decoration: InputDecoration(
                hintText: 'Số lớp ≥',
                prefixIcon: const Icon(Icons.filter_list, size: 20),
                contentPadding: EdgeInsets.zero,
                isDense: true,
                suffixIcon: _filterCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        tooltip: 'Bỏ lọc',
                        onPressed: () {
                          _filterCtrl.clear();
                          setState(() => _filterMinClass = null);
                        },
                      )
                    : null,
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                setState(() => _filterMinClass = int.tryParse(v.trim()));
              },
            ),
          ),

          // Sort buttons
          _SortButton(
            label: 'IDGV',
            active: _sortField == _SortField.idGV,
            asc: _sortAsc,
            onTap: () => _toggleSort(_SortField.idGV),
          ),
          _SortButton(
            label: 'Họ tên',
            active: _sortField == _SortField.fullname,
            asc: _sortAsc,
            onTap: () => _toggleSort(_SortField.fullname),
          ),
          _SortButton(
            label: 'Số lớp',
            active: _sortField == _SortField.sumClass,
            asc: _sortAsc,
            onTap: () => _toggleSort(_SortField.sumClass),
          ),

          // Export
          TextButton.icon(
            onPressed: () => _exportJson(all),
            icon: const Icon(Icons.download_outlined, size: 18),
            label: const Text('Xuất JSON'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF0D2B55),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Desktop table
  // ---------------------------------------------------------------------------

  Widget _buildTable(List<Lecturer> lecturers) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          sortColumnIndex: _sortField.index,
          sortAscending: _sortAsc,
          columns: [
            DataColumn(label: const Text('IDGV'), onSort: _sortById),
            const DataColumn(label: Text('Ảnh')),
            DataColumn(label: const Text('Họ và tên'), onSort: _sortByName),
            DataColumn(
              label: const Text('Số lớp'),
              numeric: true,
              onSort: _sortByClass,
            ),
            const DataColumn(label: Text('Thao tác')),
          ],
          rows: lecturers.map((l) => _buildRow(l)).toList(),
        ),
      ),
    );
  }

  DataRow _buildRow(Lecturer l) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            l.idGV,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D2B55),
            ),
          ),
          onTap: () => _openDetail(l),
        ),
        DataCell(
          LecturerAvatar(imageValue: l.image, size: 36, borderRadius: 4),
          onTap: () => _openDetail(l),
        ),
        DataCell(Text(l.fullname), onTap: () => _openDetail(l)),
        DataCell(
          Text(
            '${l.sumClass}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          onTap: () => _openDetail(l),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: 'Chỉnh sửa',
                onPressed: () => _openEdit(l),
                color: const Color(0xFF0D2B55),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                tooltip: 'Xóa',
                onPressed: () => _confirmDelete(l),
                color: Colors.red[700],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Mobile card list
  // ---------------------------------------------------------------------------

  Widget _buildCardList(List<Lecturer> lecturers) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: lecturers.length,
      itemBuilder: (_, i) => _buildCard(lecturers[i]),
    );
  }

  Widget _buildCard(Lecturer l) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _openDetail(l),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              LecturerAvatar(imageValue: l.image, size: 52, borderRadius: 8),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.fullname,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'IDGV: ${l.idGV}',
                      style: const TextStyle(
                        color: Color(0xFF0D2B55),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Số lớp: ${l.sumClass}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') _openEdit(l);
                  if (v == 'delete') _confirmDelete(l);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Chỉnh sửa'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text('Xóa', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty / error states
  // ---------------------------------------------------------------------------

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _query.isNotEmpty ? Icons.search_off : Icons.people_outline,
            size: 72,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _query.isNotEmpty
                ? 'Không tìm thấy giảng viên nào.'
                : 'Chưa có giảng viên nào.\nNhấn + để thêm mới.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    final isPermission =
        message.contains('permission') ||
        message.contains('PERMISSION_DENIED') ||
        message.contains('insufficient');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPermission ? Icons.lock_outline : Icons.cloud_off_outlined,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              isPermission
                  ? 'Không có quyền truy cập Firestore.\n'
                        'Kiểm tra Security Rules và UID quản trị viên.'
                  : 'Lỗi kết nối Firestore:\n$message',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF2D3748)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sort button widget
// ---------------------------------------------------------------------------

class _SortButton extends StatelessWidget {
  const _SortButton({
    required this.label,
    required this.active,
    required this.asc,
    required this.onTap,
  });

  final String label;
  final bool active;
  final bool asc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF0D2B55).withAlpha(15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active ? const Color(0xFF0D2B55) : const Color(0xFFCBD5E0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active
                    ? const Color(0xFF0D2B55)
                    : const Color(0xFF718096),
              ),
            ),
            if (active) ...[
              const SizedBox(width: 4),
              Icon(
                asc ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: const Color(0xFF0D2B55),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
