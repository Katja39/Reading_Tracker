//
// Dialog for creating or editing a dated reading-progress entry
//


import 'package:flutter/material.dart';

// Return value containing the entered page and selected progress date
class ReadingProgressUpdateResult {
  const ReadingProgressUpdateResult({
    required this.pageNumber,
    required this.progressDate,
  });

  final int? pageNumber;
  final String progressDate;
}

// Modal input for page number and progress date
class ReadingProgressUpdateDialog extends StatefulWidget {
  const ReadingProgressUpdateDialog({
    super.key,
    required this.initialPage,
    required this.totalPages,
    this.initialProgressDate,
  });

  final int? initialPage;
  final int? totalPages;
  final String? initialProgressDate;

  @override
  State<ReadingProgressUpdateDialog> createState() =>
      _ReadingProgressUpdateDialogState();
}

// Owns the page controller and selected date for the progress dialog
class _ReadingProgressUpdateDialogState
    extends State<ReadingProgressUpdateDialog> {
  late final TextEditingController _controller;
  late DateTime _selectedDate;

  // Initializes the page field and uses today when no date is provided
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialPage?.toString() ?? '',
    );
    final now = DateTime.now();
    final parsedDate = widget.initialProgressDate == null
        ? null
        : DateTime.tryParse(widget.initialProgressDate!);
    _selectedDate = parsedDate == null
        ? DateTime(now.year, now.month, now.day)
        : DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
  }

  // Disposes the page number controller
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Formats the selected date for backend storage
  String _dateIsoString(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  // Formats the selected date for display in the dialog
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');
    return '$day.$month.$year';
  }

  // Opens the date picker and stores the selected day
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1970),
      lastDate: today,
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
      );
    });
  }

  // Returns the parsed page number and selected date to the caller
  void _submit() {
    final page = int.tryParse(_controller.text.trim());
    Navigator.of(context).pop(
      ReadingProgressUpdateResult(
        pageNumber: page,
        progressDate: _dateIsoString(_selectedDate),
      ),
    );
  }

  // Builds the page input and date picker action
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update progress'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Current page',
              helperText: widget.totalPages == null
                  ? null
                  : 'Total pages: ${widget.totalPages}',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_outlined, size: 16),
              label: Text('Date: ${_formatDate(_selectedDate)}'),
            ),
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
          child: const Text('Save'),
        ),
      ],
    );
  }
}