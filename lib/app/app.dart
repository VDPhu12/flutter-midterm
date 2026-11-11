import 'package:flutter/material.dart';

import '../data/in_memory_item_repository.dart';
import '../screens/item_list_screen.dart';
import 'theme.dart';

/// Root widget of the application.
/// Provides the repository to child screens via the constructor parameter
/// (simple, easy to swap — no provider or InheritedWidget required at this scale).
class MidtermApp extends StatelessWidget {
  MidtermApp({super.key}) : _repository = InMemoryItemRepository();

  final InMemoryItemRepository _repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Midterm Ready',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: ItemListScreen(repository: _repository),
    );
  }
}
