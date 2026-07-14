import 'package:flutter/material.dart';

class ReadingProgressUpdateResult {
  const ReadingProgressUpdateResult({
    required this.pageNumber,
    required this.progressDate,
  });

  final int? pageNumber;
  final String progressDate;
}

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

class _ReadingProgressUpdateDialogState
    extends State<ReadingProgressUpdateDialog> {
  late final TextEditingController _controller;
  late DateTime _selectedDate;

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _dateIsoString(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');
    return '$day.$month.$year';
  }

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

  void _submit() {
    final page = int.tryParse(_controller.text.trim());
    Navigator.of(context).pop(
      ReadingProgressUpdateResult(
        pageNumber: page,
        progressDate: _dateIsoString(_selectedDate),
      ),
    );
  }

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