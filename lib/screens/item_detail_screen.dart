import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../models/item.dart';
import 'item_form_screen.dart';

/// Read-only detail view for a single item.
/// Provides Edit and Delete actions in the AppBar.
class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({
    super.key,
    required this.item,
    required this.repository,
  });

  final Item item;
  final ItemRepository repository;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late Item _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _openEdit() async {
    final updated = await Navigator.push<Item>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ItemFormScreen(repository: widget.repository, item: _item),
      ),
    );
    if (updated != null) {
      setState(() => _item = updated);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('"${updated.title}" updated.')));
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('Are you sure you want to delete "${_item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        widget.repository.delete(_item.id);
        if (mounted) {
          Navigator.pop(context); // back to list
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('"${_item.title}" deleted.')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = _formatDate(_item.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: _openEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(_item.title, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            // Date chip
            Chip(
              avatar: const Icon(Icons.calendar_today_outlined, size: 16),
              label: Text(dateStr),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 24),
            // Description section
            if (_item.description.isNotEmpty) ...[
              Text(
                'Description',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                    80,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Text(
                  _item.description,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ] else
              Text(
                'No description provided.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 32),
            // Edit button
            ElevatedButton.icon(
              onPressed: _openEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Item'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
