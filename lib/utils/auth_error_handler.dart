import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorHandler {
  static String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'ERROR_EMAIL_ALREADY_IN_USE':
      case 'account-exists-with-different-credential':
      case 'email-already-in-use':
        return 'Email already used. Go to login page.';
      case 'ERROR_WRONG_PASSWORD':
      case 'wrong-password':
        return 'Wrong email/password combination.';
      case 'ERROR_USER_NOT_FOUND':
      case 'user-not-found':
        return 'No user found with this email.';
      case 'ERROR_USER_DISABLED':
      case 'user-disabled':
        return 'User disabled.';
      case 'ERROR_TOO_MANY_REQUESTS':
      case 'ERROR_OPERATION_NOT_ALLOWED':
      case 'operation-not-allowed':
        return 'Server error, please try again later.';
      case 'ERROR_INVALID_EMAIL':
      case 'invalid-email':
        return 'Email address is invalid.';
      case 'network-request-failed':
        return 'Please check your internet connection.';
      case 'weak-password':
        return 'Please choose a stronger password for better security.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials and try again.';
      case 'user-mismatch':
        return 'The provided credentials do not match the user.';
      case 'requires-recent-login':
        return 'Please log in again to perform this action.';
      case 'credential-already-in-use':
        return 'This account is already linked to another user.';
      default:
        print('Unhandled Firebase Auth Error Code: ${e.code}');
        print('Firebase Auth Error Message: ${e.message}');
        return 'Login failed. Please try again.';
    }
  }
}
