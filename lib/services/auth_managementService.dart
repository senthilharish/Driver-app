import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthManagementService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get driverId => _user?.uid;

  AuthManagementService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = result.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      throw _handleAuthException(e);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('An unexpected error occurred');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to sign out');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}