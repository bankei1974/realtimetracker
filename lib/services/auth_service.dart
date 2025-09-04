import 'package:firebase_auth/firebase_auth.dart';

/// A service class that encapsulates Firebase Authentication logic.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Stream of [User] objects to listen for authentication state changes.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Signs in a user with the given email and password.
  ///
  /// Throws a [FirebaseAuthException] if sign-in fails.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      // Re-throw the exception to be handled by the UI.
      rethrow;
    }
  }

  /// Creates a new user with the given email and password.
  ///
  /// Throws a [FirebaseAuthException] if registration fails.
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      // Re-throw the exception to be handled by the UI.
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
