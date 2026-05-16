import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AdminAuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<bool> isAdmin(User user) async {
    final token = await user.getIdTokenResult(true);
    if (token.claims?['admin'] == true) {
      return true;
    }

    final adminDocument = await _firestore
        .collection('admins')
        .doc(user.uid)
        .get();
    if (adminDocument.exists) {
      final data = adminDocument.data() ?? <String, dynamic>{};
      return data['active'] != false;
    }

    final userDocument = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();
    if (!userDocument.exists) {
      return false;
    }

    final data = userDocument.data() ?? <String, dynamic>{};
    final role = _firstNonEmpty([
      data['role']?.toString() ?? '',
      data['userRole']?.toString() ?? '',
      data['type']?.toString() ?? '',
      data['accountType']?.toString() ?? '',
    ]).toLowerCase();
    return _toBool(data['isAdmin']) ||
        _toBool(data['admin']) ||
        _toBool(data['is_admin']) ||
        role == 'admin' ||
        role == 'administrator' ||
        role.contains('admin');
  }
}

String _firstNonEmpty(Iterable<String> values) {
  for (final value in values) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return '';
}

bool _toBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' ||
        normalized == 'yes' ||
        normalized == '1' ||
        normalized == 'admin';
  }
  return false;
}
