import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../models/item.dart';

/// Add / Edit form screen.
/// Pass [item] to edit an existing one; leave it null to create a new item.
/// Returns the saved [Item] when popped, or null if the user cancels.
class ItemFormScreen extends StatefulWidget {
  const ItemFormScreen({super.key, required this.repository, this.item});

  final ItemRepository repository;

  /// The item to edit. Null means "create new".
  final Item? item;

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  bool _saving = false;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.item?.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final Item result;
      if (_isEditing) {
        final updated = widget.item!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
        );
        result = widget.repository.update(updated);
      } else {
        final draft = Item(
          id: '', // replaced by repository
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          createdAt: DateTime.now(),
        );
        result = widget.repository.add(draft);
      }

      if (mounted) Navigator.pop(context, result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Save failed: $e')));
        setState(() => _saving = false);
      }
    }
  }

  void _cancel() => Navigator.pop(context);

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Item' : 'New Item'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel',
          onPressed: _cancel,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title field
            TextFormField(
              key: const Key('titleField'),
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter a title',
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required.';
                }
                if (value.trim().length < 2) {
                  return 'Title must be at least 2 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              key: const Key('descriptionField'),
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Optional details…',
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              minLines: 3,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 24),

            // Save button (also at bottom for thumb reach)
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Save Changes' : 'Create Item'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _cancel, child: const Text('Cancel')),
          ],
        ),
      ),
    );
  }
}
