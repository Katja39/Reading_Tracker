part of 'book_page.dart';

extension _BookPageStatisticsSection on _BookPageState {
  Widget _buildStatisticsTab(ThemeData theme) {
    return Center(
      child: Text(
        'This page is empty.',
        style: theme.textTheme.bodyLarge,
      ),
    );
  }
}


