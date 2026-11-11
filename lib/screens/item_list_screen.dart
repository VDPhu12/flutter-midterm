import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../models/item.dart';
import '../screens/item_detail_screen.dart';
import '../screens/item_form_screen.dart';
import '../widgets/item_card.dart';

/// Main list screen: shows all items, search bar, empty state,
/// and add/edit/delete actions.
class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key, required this.repository});

  final ItemRepository repository;

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  late List<Item> _displayed;
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _displayed = widget.repository.getAll().toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Data helpers
  // ---------------------------------------------------------------------------

  void _refresh([String query = '']) {
    setState(() {
      _displayed = widget.repository.search(query).toList();
    });
  }

  void _onSearchChanged(String query) => _refresh(query);

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  Future<void> _openDetail(Item item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ItemDetailScreen(item: item, repository: widget.repository),
      ),
    );
    _refresh(_searchController.text);
  }

  Future<void> _openAddForm() async {
    final added = await Navigator.push<Item>(
      context,
      MaterialPageRoute(
        builder: (_) => ItemFormScreen(repository: widget.repository),
      ),
    );
    if (added != null) {
      _refresh(_searchController.text);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('"${added.title}" added.')));
      }
    }
  }

  Future<void> _openEditForm(Item item) async {
    final updated = await Navigator.push<Item>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ItemFormScreen(repository: widget.repository, item: item),
      ),
    );
    if (updated != null) {
      _refresh(_searchController.text);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('"${updated.title}" updated.')));
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  Future<void> _confirmDelete(Item item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('Are you sure you want to delete "${item.title}"?'),
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
        widget.repository.delete(item.id);
        _refresh(_searchController.text);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('"${item.title}" deleted.')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search…',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary
                        .withAlpha(180),
                  ),
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: _onSearchChanged,
              )
            : const Text('Items'),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close search',
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
                _refresh();
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search',
              onPressed: () => setState(() => _isSearching = true),
            ),
        ],
      ),
      body: _displayed.isEmpty ? _buildEmptyState() : _buildList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddForm,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88), // room for FAB
      itemCount: _displayed.length,
      itemBuilder: (_, index) {
        final item = _displayed[index];
        return ItemCard(
          item: item,
          onTap: () => _openDetail(item),
          onEdit: () => _openEditForm(item),
          onDelete: () => _confirmDelete(item),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final isFiltered = _searchController.text.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFiltered ? Icons.search_off : Icons.inbox_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered
                  ? 'No results for "${_searchController.text}"'
                  : 'No items yet',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.outline),
              textAlign: TextAlign.center,
            ),
            if (!isFiltered) ...[
              const SizedBox(height: 8),
              Text(
                'Tap the + button to add your first item.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
