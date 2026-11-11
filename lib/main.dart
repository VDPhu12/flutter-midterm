import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter engine is ready before calling platform plugins.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only if it has not already been initialized.
  // (Guards against accidental double-initialization in test environments.)
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(MidtermApp());
}
