import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/auth_service.dart';
import '../data/firestore_lecturer_repository.dart';
import '../data/image_service.dart';
import '../screens/lecturer_list_screen.dart';
import '../screens/login_screen.dart';
import 'theme.dart';

/// Root of the application.
/// Uses an auth-state stream to decide whether to show Login or Management screen.
class GiangVienApp extends StatelessWidget {
  GiangVienApp({super.key})
    : _auth = AuthService(),
      _repo = FirestoreLecturerRepository(),
      _imageService = ImageService();

  final AuthService _auth;
  final FirestoreLecturerRepository _repo;
  final ImageService _imageService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý Giảng Viên',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: StreamBuilder<User?>(
        stream: _auth.authStateChanges,
        builder: (context, snap) {
          // Waiting for Firebase to restore session
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final user = snap.data;

          if (user == null) {
            return LoginScreen(authService: _auth);
          }

          return LecturerListScreen(
            repository: _repo,
            authService: _auth,
            imageService: _imageService,
            user: user,
          );
        },
      ),
    );
  }
}
