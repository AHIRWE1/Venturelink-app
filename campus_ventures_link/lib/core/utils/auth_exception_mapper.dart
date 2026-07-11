import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

String mapFirebaseAuthException(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'The email address is invalid.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'user-not-found':
      return 'No account found with this email.';
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'email-already-in-use':
      return 'An account already exists with this email.';
    case 'weak-password':
      return 'Password is too weak. Use at least 6 characters.';
    case 'invalid-credential':
      return 'Invalid email or password.';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later.';
    case 'network-request-failed':
      return 'Network error. Check your connection.';
    default:
      return e.message ?? 'Authentication failed. Please try again.';
  }
}
