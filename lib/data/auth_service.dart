import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around FirebaseAuth — only email/password, no signup UI.
class AuthService {
  AuthService() : _auth = FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Stream of auth state changes. Emits the current [User] or null.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// The currently signed-in user, or null.
  User? get currentUser => _auth.currentUser;

  /// Signs in with email and password.
  /// Throws [FirebaseAuthException] on failure.
  Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  /// Signs out the current user.
  Future<void> signOut() => _auth.signOut();
}
