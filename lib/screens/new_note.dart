import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:notes/providers/notes_provider.dart';

class NewNoteScreen extends ConsumerStatefulWidget {
  const NewNoteScreen({super.key});

  @override
  ConsumerState<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends ConsumerState<NewNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNewNote() {
    String enteredTitle = _titleController.text.trim().isEmpty
        ? 'Không có tiêu đề'
        : _titleController.text.trim();
    String enteredContent =
        _contentController.text.trim().isEmpty ? '' : _contentController.text;
    DateTime date = DateTime.now();

    ref
        .watch(notesProvider.notifier)
        .addNewNote(enteredTitle, enteredContent, date);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Lưu',
            onPressed: _saveNewNote,
            icon: const Icon(Icons.save),
          ),
          IconButton(
            tooltip: 'Đính kèm tệp',
            onPressed: () {},
            icon: const Icon(Icons.attach_file_rounded),
          ),
        ],
        title: TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'Tiêu đề',
            border: InputBorder.none,
          ),
        ),
      ),
      body: TextField(
        controller: _contentController,
        maxLength: 1024,
        maxLines: null,
        autocorrect: false,
        autofocus: true,
        cursorColor: Colors.red,
        buildCounter: (context,
                {int? currentLength, bool? isFocused, int? maxLength}) =>
            null,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
        ),
      ),
    );
  }
}
