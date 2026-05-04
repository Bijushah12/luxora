import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/admin_auth_service.dart';

class AdminAuthProvider extends ChangeNotifier {
  final AdminAuthService _service;
  StreamSubscription<User?>? _subscription;

  User? _user;
  bool _isAdmin = false;
  bool _isChecking = true;
  bool _isSigningIn = false;
  String? _errorMessage;
  bool _disposed = false;

  AdminAuthProvider({AdminAuthService? service})
    : _service = service ?? AdminAuthService() {
    _subscription = _service.authStateChanges().listen(_handleAuthChange);
  }

  User? get user => _user;
  bool get isAdmin => _isAdmin;
  bool get isChecking => _isChecking;
  bool get isSigningIn => _isSigningIn;
  String? get errorMessage => _errorMessage;

  Future<void> _handleAuthChange(User? user) async {
    _user = user;
    _isChecking = true;
    _errorMessage = null;
    _safeNotify();

    if (user == null) {
      _isAdmin = false;
      _isChecking = false;
      _safeNotify();
      return;
    }

    try {
      _isAdmin = await _service.isAdmin(user);
    } catch (error) {
      _isAdmin = false;
      _errorMessage = 'Unable to verify admin access. $error';
    } finally {
      _isChecking = false;
      _safeNotify();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isSigningIn = true;
    _errorMessage = null;
    _safeNotify();

    try {
      final credentials = await _service.signIn(email.trim(), password.trim());
      final signedInUser = credentials.user;

      if (signedInUser == null) {
        throw FirebaseAuthException(
          code: 'missing-user',
          message: 'No Firebase user was returned after login.',
        );
      }

      final allowed = await _service.isAdmin(signedInUser);
      if (!allowed) {
        await _service.signOut();
        _errorMessage =
            'This account is not allowed to access the admin panel.';
        return false;
      }

      _user = signedInUser;
      _isAdmin = true;
      return true;
    } on FirebaseAuthException catch (error) {
      _errorMessage = _messageForAuthError(error);
      return false;
    } catch (error) {
      _errorMessage = 'Login failed. $error';
      return false;
    } finally {
      _isSigningIn = false;
      _safeNotify();
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
  }

  void clearError() {
    _errorMessage = null;
    _safeNotify();
  }

  String _messageForAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
      case 'invalid-credential':
        return 'Invalid admin email or password.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'too-many-requests':
        return 'Too many login attempts. Try again later.';
      default:
        return error.message ?? 'Unable to login.';
    }
  }

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
