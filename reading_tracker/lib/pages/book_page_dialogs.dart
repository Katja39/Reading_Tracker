part of 'book_page.dart';

class _AddBookDialogResult {
  const _AddBookDialogResult({
    required this.title,
    required this.author,
    required this.status,
    required this.rating,
  });

  final String title;
  final String author;
  final String status;
  final double? rating;
}

class _AddBookDialog extends StatefulWidget {
  const _AddBookDialog({
    required this.statuses,
  });

  final List<String> statuses;

  @override
  State<_AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<_AddBookDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late String _selectedStatus;
  double? _selectedRating;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _authorController = TextEditingController();
    _selectedStatus = widget.statuses.first;
    _selectedRating = null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(
      _AddBookDialogResult(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        status: _selectedStatus,
        rating: _selectedRating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Book'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _authorController,
            decoration: const InputDecoration(
              labelText: 'Author',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Status',
            ),
            items: widget.statuses
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _selectedStatus = value;
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<double?>(
            initialValue: _selectedRating,
            decoration: const InputDecoration(
              labelText: 'Rating',
            ),
            items: const [
              DropdownMenuItem<double?>(
                value: null,
                child: Text('No rating'),
              ),
              DropdownMenuItem<double?>(value: 1, child: Text('1 star')),
              DropdownMenuItem<double?>(value: 2, child: Text('2 stars')),
              DropdownMenuItem<double?>(value: 3, child: Text('3 stars')),
              DropdownMenuItem<double?>(value: 4, child: Text('4 stars')),
              DropdownMenuItem<double?>(value: 5, child: Text('5 stars')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedRating = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
