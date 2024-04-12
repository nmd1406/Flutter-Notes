import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/models/note.dart';
import 'package:notes/providers/edit_state_provider.dart';
import 'package:notes/providers/notes_provider.dart';
import 'package:notes/widgets/content_text_field.dart';
import 'package:notes/widgets/files_grid_view.dart';
import 'package:path_provider/path_provider.dart';

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
  bool _isEditing = false;
  bool _isSaved = false;
  late final List<PlatformFile> _pickedFiles = widget.note.files;

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

  void _editNote() {
    setState(() {
      _isEditing = true;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
  }

  void _saveEditedNote() {
    String editedTitle = _titleController.text.trim().isEmpty
        ? 'Không có tiêu đề'
        : _titleController.text.trim();
    String editedContent =
        _contentController.text.trim().isEmpty ? '' : _contentController.text;
    DateTime date = DateTime.now();

    ref.watch(notesProvider.notifier).saveEditedNote(
          widget.note,
          editedTitle,
          editedContent,
          date,
          _pickedFiles,
        );

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 3),
        content: Text('Đã lưu thay đổi'),
      ),
    );

    setState(() {
      _isEditing = false;
      _isSaved = true;
    });
  }

  void _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) {
      return;
    }

    // ref
    //     .watch(notesProvider.notifier)
    //     .updateNoteFiles(widget.note, result.files);

    setState(() {
      _pickedFiles.addAll(result.files);
    });
  }

  Future<File> _saveFile(PlatformFile file) {
    final appDir = getApplicationDocumentsDirectory();
    final newFile = File('$appDir/${file.name}');

    return File(file.path!).copy(newFile.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autocorrect: false,
          controller: _titleController,
          enabled: _isEditing,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Tiêu đề',
          ),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              tooltip: 'Sửa',
              onPressed: _editNote,
              icon: const Icon(Icons.edit_document),
            )
          else
            IconButton(
              tooltip: 'Lưu thay đổi',
              onPressed: _saveEditedNote,
              icon: const Icon(Icons.save),
            ),
          if (_isEditing)
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
          PopupMenuButton(
            tooltip: 'Tuỳ chọn khác',
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.star_border),
                  title: Text('Thêm vào mục yêu thích'),
                ),
                onTap: () {},
              ),
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.lock_open),
                  title: Text('Mở khoá'),
                ),
                onTap: () {},
              ),
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Xoá'),
                ),
                onTap: () {},
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              autocorrect: false,
              controller: _contentController,
              enabled: _isEditing,
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
            if (_isSaved)
              FileGridView(
                files: widget.note.files,
              )
            else
              FileGridView(
                files: _pickedFiles,
              )
          ],
        ),
      ),
    );
  }
}
