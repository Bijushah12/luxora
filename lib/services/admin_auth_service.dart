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
    final role = data['role']?.toString().toLowerCase();
    return data['isAdmin'] == true || role == 'admin';
  }
}
