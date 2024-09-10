// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:notes/models/note.dart';
import 'package:notes/providers/notes_provider.dart';
import 'package:notes/widgets/file_view/files_grid_view.dart';

class NoteDetailsScreen extends ConsumerStatefulWidget {
  final Note note;

  const NoteDetailsScreen({
    super.key,
    required this.note,
  });

  @override
  ConsumerState<NoteDetailsScreen> createState() {
    return _NoteDetailsScreenState();
  }
}

class _NoteDetailsScreenState extends ConsumerState<NoteDetailsScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late final List<File> _files = [...widget.note.files];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveEditedNote() async {
    String editedTitle = _titleController.text.trim().isEmpty
        ? 'Tiêu đề'
        : _titleController.text.trim();
    String editedContent =
        _contentController.text.trim().isEmpty ? '' : _contentController.text;
    DateTime date = DateTime.now();

    List<File> saveFiles = [];
    for (var file in _files) {
      final newFile = await _saveFile(file);
      saveFiles.add(newFile);
    }

    if (widget.note.files.length != saveFiles.length) {
      ref.watch(notesProvider.notifier).saveEditedNote(
            widget.note,
            editedTitle,
            editedContent,
            date,
            saveFiles,
          );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 3),
          content: Text('Đã lưu thay đổi'),
        ),
      );
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
      _files.addAll(files);
    });
  }

  Future<File> _saveFile(File file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final newFile = File('${appDir.path}/${path.basename(file.path)}');

    return File(file.path).copy(newFile.path);
  }

  void _deleteFile(File file) {
    setState(() {
      _files.remove(file);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autocorrect: false,
          controller: _titleController,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Tiêu đề',
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Lưu thay đổi',
            onPressed: _saveEditedNote,
            icon: const Icon(Icons.save_outlined),
          ),
          IconButton(
            tooltip: 'Đính kèm tệp',
            onPressed: _pickFiles,
            icon: const Icon(Icons.attach_file_rounded),
          ),
          IconButton(
            tooltip: 'Tìm kiếm',
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
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
              files: _files,
              onDeleteFile: _deleteFile,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
