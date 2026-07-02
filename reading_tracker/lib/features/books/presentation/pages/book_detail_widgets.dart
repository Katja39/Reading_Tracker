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

class _BookDetailSection extends StatelessWidget {
  const _BookDetailSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 16.0;
            final useColumns = constraints.maxWidth >= 640;
            final itemWidth = useColumns
                ? (constraints.maxWidth - spacing) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: spacing,
              runSpacing: 12,
              children: children
                  .map(
                    (child) => SizedBox(
                      width: itemWidth,
                      child: child,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
class _BookHeaderRating extends StatelessWidget {
  const _BookHeaderRating({required this.rating, required this.onTap});

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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final icon = switch (index) {
              _ when index < fullStars => Icons.star,
              _ when index == fullStars && hasHalfStar => Icons.star_half,
              _ => Icons.star_border,
            };

            return Icon(icon, color: theme.colorScheme.primary, size: 22);
          }),
        ),
      ),
    );
  }
}


class _BookStatusButton extends StatelessWidget {
  const _BookStatusButton({
    required this.status,
    required this.onPressed,
  });

  final String status;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        backgroundColor: theme.colorScheme.primaryContainer,
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(status),
    );
  }
}






