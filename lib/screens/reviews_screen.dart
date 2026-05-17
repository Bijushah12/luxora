import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/review_model.dart';
import '../providers/reviews_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/theme_toggle_button.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final TextEditingController _reviewController = TextEditingController();
  final FocusNode _reviewFocusNode = FocusNode();
  int _rating = 0;

  @override
  void dispose() {
    _reviewController.dispose();
    _reviewFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final message = _reviewController.text.trim();
    if (_rating == 0 || message.isEmpty) {
      _showSnackBar('Please add a rating and review text.', isError: true);
      return;
    }
    if (message.length < 3) {
      _showSnackBar('Please add a little more detail.', isError: true);
      return;
    }

    final success = await context.read<ReviewsProvider>().submitReview(
      rating: _rating,
      message: message,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      _reviewController.clear();
      _reviewFocusNode.unfocus();
      setState(() => _rating = 0);
      _showSnackBar('Review submitted successfully.');
    } else {
      final error = context.read<ReviewsProvider>().errorMessage;
      _showSnackBar(error ?? 'Unable to submit review.', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    final reviewsProvider = context.watch<ReviewsProvider>();
    final reviews = reviewsProvider.reviews;
    final summary = reviewsProvider.summary;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
        title: Text(
          'Reviews & Feedback',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: const [ThemeToggleButton()],
      ),
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: _buildSummaryCard(
                summary: summary,
                isLoading: reviewsProvider.isLoading,
              ),
            ),
            if (reviewsProvider.errorMessage != null ||
                reviewsProvider.successMessage != null)
              SliverToBoxAdapter(
                child: _buildFeedbackBanner(
                  error: reviewsProvider.errorMessage,
                  success: reviewsProvider.successMessage,
                  onClose: reviewsProvider.clearMessages,
                ),
              ),
            SliverToBoxAdapter(
              child: _buildReviewComposer(reviewsProvider.isSubmitting),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Latest Reviews',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '${summary.totalReviews}',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (reviewsProvider.isLoading && reviews.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              )
            else if (reviews.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildReviewCard(reviews[index]),
                    );
                  }, childCount: reviews.length),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.viewInsetsOf(context).bottom + 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required ReviewSummary summary,
    required bool isLoading,
  }) {
    final reviewLabel = summary.totalReviews == 1 ? 'review' : 'reviews';
    final averageText = summary.totalReviews == 0
        ? '0.0'
        : summary.averageRating.toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.card, AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 340;
              final scoreBlock = Column(
                crossAxisAlignment: isCompact
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    averageText,
                    style: TextStyle(
                      fontSize: 46,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildStars(rating: summary.averageRating, size: 19),
                  const SizedBox(height: 5),
                  Text(
                    isLoading && summary.totalReviews == 0
                        ? 'Loading reviews'
                        : '${summary.totalReviews} $reviewLabel',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              );

              final bars = Column(
                children: [5, 4, 3, 2, 1]
                    .map((star) => _buildRatingBar(star, summary))
                    .toList(growable: false),
              );

              if (isCompact) {
                return Column(
                  children: [scoreBlock, const SizedBox(height: 18), bars],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  scoreBlock,
                  const SizedBox(width: 24),
                  Expanded(child: bars),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int star, ReviewSummary summary) {
    final count = summary.ratingCounts[star] ?? 0;
    final percentage = summary.totalReviews == 0
        ? 0.0
        : count / summary.totalReviews;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Row(
              children: [
                Text(
                  '$star',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(Icons.star, color: AppColors.accent, size: 12),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                minHeight: 7,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackBanner({
    required String? error,
    required String? success,
    required VoidCallback onClose,
  }) {
    final message = error ?? success;
    if (message == null || message.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final isError = error != null;
    final color = isError ? AppColors.error : AppColors.success;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close, color: color, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewComposer(bool isSubmitting) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rate_review_outlined, color: AppColors.accent),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Share your feedback',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Center(child: _buildInteractiveStars(isSubmitting)),
          const SizedBox(height: 14),
          TextField(
            controller: _reviewController,
            focusNode: _reviewFocusNode,
            enabled: !isSubmitting,
            minLines: 2,
            maxLines: 4,
            maxLength: 800,
            style: TextStyle(color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'Share your experience with Luxora...',
              hintStyle: TextStyle(color: AppColors.textLight),
              counterStyle: TextStyle(color: AppColors.textLight, fontSize: 11),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.accent, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: isSubmitting ? null : _submitReview,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textInverse,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: isSubmitting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textInverse,
                      ),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(
                isSubmitting ? 'Submitting...' : 'Submit Review',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveStars(bool isSubmitting) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final selected = index < _rating;
        return IconButton(
          tooltip: '${index + 1} star',
          onPressed: isSubmitting
              ? null
              : () {
                  setState(() => _rating = index + 1);
                },
          visualDensity: VisualDensity.compact,
          icon: Icon(
            selected ? Icons.star_rounded : Icons.star_border_rounded,
            color: AppColors.accent,
            size: 34,
          ),
        );
      }),
    );
  }

  Widget _buildReviewCard(AppReview review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(review),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _relativeDate(review.createdAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStars(rating: review.rating.toDouble(), size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.message,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(AppReview review) {
    final imageUrl = review.userPhotoUrl.trim();
    return CircleAvatar(
      radius: 23,
      backgroundColor: AppColors.accent.withValues(alpha: 0.16),
      backgroundImage: imageUrl.isEmpty ? null : NetworkImage(imageUrl),
      child: imageUrl.isEmpty
          ? Text(
              review.initials,
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w900,
              ),
            )
          : null,
    );
  }

  Widget _buildStars({required double rating, required double size}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final icon = rating >= starValue
            ? Icons.star_rounded
            : rating >= starValue - 0.5
            ? Icons.star_half_rounded
            : Icons.star_border_rounded;
        return Icon(icon, color: AppColors.accent, size: size);
      }),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.reviews_outlined, color: AppColors.accent, size: 38),
          SizedBox(height: 12),
          Text(
            'No reviews yet',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Be the first to share your Luxora experience.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _relativeDate(DateTime? date) {
    if (date == null) {
      return 'Just now';
    }

    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inHours < 1) {
      return _plural(difference.inMinutes, 'minute');
    }
    if (difference.inDays < 1) {
      return _plural(difference.inHours, 'hour');
    }
    if (difference.inDays < 7) {
      return _plural(difference.inDays, 'day');
    }
    if (difference.inDays < 30) {
      return _plural((difference.inDays / 7).floor(), 'week');
    }
    if (difference.inDays < 365) {
      return _plural((difference.inDays / 30).floor(), 'month');
    }
    return _plural((difference.inDays / 365).floor(), 'year');
  }

  String _plural(int value, String unit) {
    return '$value $unit${value == 1 ? '' : 's'} ago';
  }
}
