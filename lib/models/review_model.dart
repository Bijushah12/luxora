import 'package:cloud_firestore/cloud_firestore.dart';

class AppReview {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhotoUrl;
  final int rating;
  final String message;
  final String status;
  final DateTime? createdAt;

  const AppReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhotoUrl,
    required this.rating,
    required this.message,
    required this.status,
    this.createdAt,
  });

  factory AppReview.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return AppReview(
      id: snapshot.id,
      userId: _string(data['userId']),
      userName: _string(data['userName']).trim().isEmpty
          ? 'Luxora Member'
          : _string(data['userName']).trim(),
      userEmail: _string(data['userEmail']),
      userPhotoUrl: _string(data['userPhotoUrl']),
      rating: _ratingFrom(data['rating']),
      message: _string(data['message']),
      status: _string(data['status']).trim().isEmpty
          ? 'published'
          : _string(data['status']).trim(),
      createdAt: _toDateTime(data['createdAt']),
    );
  }

  String get initials {
    final parts = userName
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return 'L';
    }
    final first = parts.first[0];
    final second = parts.length > 1 ? parts.last[0] : '';
    return '$first$second'.toUpperCase();
  }

  static int _ratingFrom(dynamic value) {
    if (value is int) {
      return value.clamp(1, 5);
    }
    if (value is num) {
      return value.round().clamp(1, 5);
    }
    if (value is String) {
      return (int.tryParse(value) ?? 1).clamp(1, 5);
    }
    return 1;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static String _string(dynamic value) => value?.toString() ?? '';
}

class ReviewSummary {
  final int totalReviews;
  final double averageRating;
  final Map<int, int> ratingCounts;

  const ReviewSummary({
    required this.totalReviews,
    required this.averageRating,
    required this.ratingCounts,
  });

  factory ReviewSummary.fromReviews(List<AppReview> reviews) {
    final counts = {for (var rating = 1; rating <= 5; rating++) rating: 0};
    var totalRating = 0;

    for (final review in reviews) {
      final rating = review.rating.clamp(1, 5);
      counts[rating] = (counts[rating] ?? 0) + 1;
      totalRating += rating;
    }

    return ReviewSummary(
      totalReviews: reviews.length,
      averageRating: reviews.isEmpty ? 0 : totalRating / reviews.length,
      ratingCounts: counts,
    );
  }
}
