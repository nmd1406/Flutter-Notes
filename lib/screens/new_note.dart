// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import 'package:notes/providers/notes_provider.dart';
import 'package:notes/widgets/file_view/files_grid_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class NewNoteScreen extends ConsumerStatefulWidget {
  const NewNoteScreen({super.key});

  @override
  ConsumerState<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends ConsumerState<NewNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final List<File> _pickedFiles = [];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNewNote() async {
    String enteredTitle = _titleController.text.trim().isEmpty
        ? 'Tiêu đề'
        : _titleController.text.trim();
    String enteredContent =
        _contentController.text.trim().isEmpty ? '' : _contentController.text;
    DateTime date = DateTime.now();

    List<File> saveFiles = [];
    for (var file in _pickedFiles) {
      final newFile = await _saveFile(file);
      saveFiles.add(newFile);
    }

    ref
        .watch(notesProvider.notifier)
        .addNewNote(enteredTitle, enteredContent, date, saveFiles);

    setState(() {
      _pickedFiles.clear();
    });

    if (context.mounted) {
      Navigator.of(context).pop();
    } else {
      return;
    }
  }

  void _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) {
      return;
    }

    List<File> files = [];
    for (var file in result.files) {
      final newFile = File(file.path!);
      files.add(newFile);
    }

    setState(() {
      _pickedFiles.addAll(files);
    });
  }

  Future<File> _saveFile(File file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final newFile = File('${appDir.path}/${path.basename(file.path)}');

    return File(file.path).copy(newFile.path);
  }

  void _deleteFile(File file) {
    setState(() {
      _pickedFiles.remove(file);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Lưu',
            onPressed: _saveNewNote,
            icon: const Icon(Icons.save_outlined),
          ),
          IconButton(
            tooltip: 'Đính kèm tệp',
            onPressed: _pickFiles,
            icon: const Icon(Icons.attach_file_rounded),
          ),
        ],
        title: TextField(
          controller: _titleController,
          textCapitalization: TextCapitalization.sentences,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w500,
              ),
          decoration: const InputDecoration(
            hintText: 'Tiêu đề',
            border: InputBorder.none,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              autocorrect: false,
              controller: _contentController,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 1024,
              maxLines: null,
              cursorColor: Colors.red,
              buildCounter: (context,
                      {int? currentLength, bool? isFocused, int? maxLength}) =>
                  null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(15),
                hintText: 'Ghi chú ở đây...',
              ),
            ),
            FileGridView(
              files: _pickedFiles,
              onDeleteFile: _deleteFile,
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
