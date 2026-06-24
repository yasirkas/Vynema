import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A small pill showing a star icon and a vote average (e.g. "★ 8.4").
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.voteAverage, this.compact = false});

  final double voteAverage;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.star, size: 14),
          const SizedBox(width: 2),
          Text(
            voteAverage.toStringAsFixed(1),
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
