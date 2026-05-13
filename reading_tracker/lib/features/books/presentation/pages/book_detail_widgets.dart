part of 'book_detail_page.dart';

class _BookDetailRow extends StatelessWidget {
  const _BookDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

class _BookRatingRow extends StatelessWidget {
  const _BookRatingRow({required this.rating, required this.onTap});

  final double? rating;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveRating = (rating ?? 0).clamp(0, 5);
    final fullStars = effectiveRating.floor();
    final hasHalfStar = effectiveRating - fullStars >= 0.5;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rating', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Row(
              children: [
                ...List.generate(5, (index) {
                  final icon = switch (index) {
                    _ when index < fullStars => Icons.star,
                    _ when index == fullStars && hasHalfStar => Icons.star_half,
                    _ => Icons.star_border,
                  };

                  return Icon(icon, color: theme.colorScheme.primary);
                }),
                const SizedBox(width: 8),
                Text('Tap to edit', style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
