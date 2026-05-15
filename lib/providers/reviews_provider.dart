import 'dart:async';

import 'package:flutter/material.dart';

import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewsProvider extends ChangeNotifier {
  final ReviewService _service;
  StreamSubscription<List<AppReview>>? _subscription;

  List<AppReview> _reviews = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;
  bool _disposed = false;

  ReviewsProvider({ReviewService? service})
    : _service = service ?? ReviewService() {
    _subscription = _service.reviewsStream().listen(
      (reviews) {
        _reviews = reviews;
        _isLoading = false;
        _errorMessage = null;
        _safeNotify();
      },
      onError: (Object error) {
        _reviews = [];
        _isLoading = false;
        _errorMessage = 'Unable to load reviews. $error';
        _safeNotify();
      },
    );
  }

  List<AppReview> get reviews => List.unmodifiable(_reviews);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  ReviewSummary get summary => ReviewSummary.fromReviews(_reviews);

  Future<bool> submitReview({
    required int rating,
    required String message,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    _safeNotify();

    try {
      await _service.submitReview(rating: rating, message: message);
      _successMessage = 'Review submitted successfully.';
      return true;
    } catch (error) {
      _errorMessage = 'Unable to submit review. $error';
      return false;
    } finally {
      _isSubmitting = false;
      _safeNotify();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _safeNotify();
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
