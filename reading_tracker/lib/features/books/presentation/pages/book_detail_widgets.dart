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
        ...children.expand(
          (child) => [
            child,
            const SizedBox(height: 12),
          ],
        ).take(children.length * 2 - 1),
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
  const _BookStatusButton({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton.tonal(
      onPressed: () {},
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


