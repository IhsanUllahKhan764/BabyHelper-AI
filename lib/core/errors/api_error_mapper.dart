import 'package:firebase_auth/firebase_auth.dart';
import 'package:baby_helper_ai/core/errors/failure.dart';

/// Maps Firebase and general exceptions to typed Failure objects
class ApiErrorMapper {
  ApiErrorMapper._();

  static Failure map(dynamic error) {
    if (error is FirebaseAuthException) {
      return _mapFirebaseAuth(error);
    }
    if (error is FirebaseException) {
      return FirebaseFailure(error.code, error.message ?? 'Firebase error');
    }
    if (error is Failure) {
      return error;
    }
    return const UnknownFailure();
  }

  static Failure _mapFirebaseAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const FirebaseFailure('user-not-found', 'No account found with this email');
      case 'wrong-password':
        return const FirebaseFailure('wrong-password', 'Incorrect password');
      case 'email-already-in-use':
        return const FirebaseFailure('email-already-in-use', 'Email is already registered');
      case 'weak-password':
        return const FirebaseFailure('weak-password', 'Password is too weak');
      case 'invalid-email':
        return const FirebaseFailure('invalid-email', 'Invalid email address');
      case 'too-many-requests':
        return const FirebaseFailure('too-many-requests', 'Too many attempts. Please try later.');
      case 'network-request-failed':
        return const NetworkFailure();
      case 'invalid-credential':
        return const FirebaseFailure('invalid-credential', 'Invalid email or password');
      default:
        return FirebaseFailure(e.code, e.message ?? 'Authentication error');
    }
  }
}
