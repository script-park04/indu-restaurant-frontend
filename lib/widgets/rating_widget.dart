import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final bool showValue;
  final int? reviewCount;
  final Function(int)? onRatingChanged;

  const RatingWidget({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
    this.showValue = true,
    this.reviewCount,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (onRatingChanged != null) {
      // Interactive mode
      return _buildInteractiveRating(context);
    } else {
      // Display mode
      return _buildDisplayRating(context);
    }
  }

  Widget _buildDisplayRating(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxRating, (index) {
          final starValue = index + 1;
          return Icon(
            starValue <= rating
                ? Icons.star
                : starValue - 0.5 <= rating
                    ? Icons.star_half
                    : Icons.star_border,
            color: Colors.amber,
            size: size,
          );
        }),
        if (showValue) ...[
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.875,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: size * 0.75,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInteractiveRating(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starValue = index + 1;
        return GestureDetector(
          onTap: () => onRatingChanged!(starValue),
          child: Icon(
            starValue <= rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: size,
          ),
        );
      }),
    );
  }
}
