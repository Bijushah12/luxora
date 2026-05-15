import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ReviewService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _firestore.collection('reviews');

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<List<AppReview>> reviewsStream() {
    return _reviews.where('status', isEqualTo: 'published').snapshots().map((
      snapshot,
    ) {
      final reviews = snapshot.docs
          .map(AppReview.fromFirestore)
          .where((review) => review.message.trim().isNotEmpty)
          .toList(growable: false);
      return _sortNewestFirst(reviews);
    });
  }

  Future<void> submitReview({
    required int rating,
    required String message,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Please login before writing a review.',
      );
    }

    final cleanMessage = message.trim();
    if (cleanMessage.isEmpty) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'empty-review',
        message: 'Review text is required.',
      );
    }

    final profile = await _userProfile(user.uid);
    final displayName = _firstNonEmpty([
      _string(profile['name']),
      _string(profile['fullName']),
      user.displayName ?? '',
      _nameFromEmail(user.email),
      'Luxora Member',
    ]);
    final userEmail = _firstNonEmpty([
      _string(profile['email']),
      user.email ?? '',
    ]);
    final photoUrl = _firstNonEmpty([
      _string(profile['photoUrl']),
      _string(profile['avatarUrl']),
      user.photoURL ?? '',
    ]);
    final safeRating = rating.clamp(1, 5).toInt();

    await _reviews.add({
      'userId': user.uid,
      'userName': displayName,
      'userEmail': userEmail,
      'userPhotoUrl': photoUrl,
      'rating': safeRating,
      'message': cleanMessage,
      'status': 'published',
      'source': 'reviews_screen',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>> _userProfile(String userId) async {
    try {
      final snapshot = await _users.doc(userId).get();
      return snapshot.data() ?? <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  List<AppReview> _sortNewestFirst(List<AppReview> reviews) {
    return [...reviews]..sort((a, b) {
      final left = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final right = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return right.compareTo(left);
    });
  }

  String _nameFromEmail(String? email) {
    final text = email?.trim() ?? '';
    if (text.isEmpty || !text.contains('@')) {
      return '';
    }
    return text.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ').trim();
  }

  String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      final clean = value.trim();
      if (clean.isNotEmpty) {
        return clean;
      }
    }
    return '';
  }

  String _string(dynamic value) => value?.toString() ?? '';
}
