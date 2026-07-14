//
// Statistics tab section for library summary content
//


part of 'library_page.dart';

// Adds statistics tab builders to the library page state
extension _LibraryPageStatisticsSection on _LibraryPageState {
  // Builds the current placeholder statistics view
  Widget _buildStatisticsTab(ThemeData theme) {
    return Center(
      child: Text(
        'This page is empty.',
        style: theme.textTheme.bodyLarge,
      ),
    );
  }
}


