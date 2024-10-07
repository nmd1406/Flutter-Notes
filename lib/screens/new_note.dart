// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:notes/providers/notes_provider.dart';
import 'package:notes/widgets/file_view/files_grid_view.dart';
import 'package:notes/models/note.dart';

const uuid = Uuid();

class NewNoteScreen extends ConsumerStatefulWidget {
  const NewNoteScreen({super.key});

  @override
  ConsumerState<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends ConsumerState<NewNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = quill.QuillController.basic();
  final List<File> _pickedFiles = [];

  @override
  void initState() {
    super.initState();
  }

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
    String plainText = _contentController.document.toPlainText().trim();
    String enteredContent = plainText.isEmpty ? '' : plainText;
    DateTime date = DateTime.now();
    String quillState =
        jsonEncode(_contentController.document.toDelta().toJson());

    String id = uuid.v4();

    List<File> savedFiles = [];
    for (int i = 0; i < _pickedFiles.length; ++i) {
      File savedFile = await _saveFile(_pickedFiles[i], id);
      savedFiles.add(savedFile);
    }

    Note newNote = Note(
      id: uuid.v4(),
      title: enteredTitle,
      content: enteredContent,
      quillState: quillState,
      dateCreated: date,
      files: savedFiles,
    );

    ref.watch(notesProvider.notifier).addNewNote(newNote, _pickedFiles);

    if (context.mounted) {
      Navigator.of(context).pop();
    }

    return;
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

  Future<File> _saveFile(File file, String noteId) async {
    final appDir = await getExternalStorageDirectory();
    final dirPath = '${appDir!.path}/$noteId';
    final newFilePath = '${appDir.path}/$noteId/${path.basename(file.path)}';

    final dir = Directory(dirPath);
    await dir.create(recursive: true);

    final copiedFile = await file.copy(newFilePath);
    return copiedFile;
  }

  void _deleteFile(File file) {
    setState(() {
      _pickedFiles.remove(file);
    });
  }

  List<Widget> _buildActions() {
    return [
      IconButton(
        tooltip: 'Lưu thay đổi',
        onPressed: _saveNewNote,
        icon: const Icon(Icons.save_outlined),
      ),
      IconButton(
        tooltip: 'Đính kèm tệp',
        onPressed: _pickFiles,
        icon: const Icon(Icons.attach_file_rounded),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: TextField(
          autocorrect: false,
          controller: _titleController,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w500,
              ),
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Tiêu đề',
          ),
        ),
        actions: _buildActions(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            quill.QuillEditor.basic(
              controller: _contentController,
              configurations: quill.QuillEditorConfigurations(
                padding: const EdgeInsets.all(15),
                placeholder: 'Ghi chú ở đây...',
                customStyles: quill.DefaultStyles(
                  placeHolder: quill.DefaultTextBlockStyle(
                    Theme.of(context).textTheme.bodyLarge!,
                    quill.HorizontalSpacing.zero,
                    quill.VerticalSpacing.zero,
                    quill.VerticalSpacing.zero,
                    null,
                  ),
                ),
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
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: quill.QuillSimpleToolbar(
          controller: _contentController,
          configurations: const quill.QuillSimpleToolbarConfigurations(
            multiRowsDisplay: false,
            showFontFamily: false,
            showInlineCode: false,
            showCodeBlock: false,
            showSearchButton: true,
            showLink: false,
            showQuote: false,
            showStrikeThrough: false,
            showClearFormat: false,
            showClipboardPaste: false,
            showClipboardCopy: false,
            showClipboardCut: false,
          ),
        ),
      ),
    );
  }
}
