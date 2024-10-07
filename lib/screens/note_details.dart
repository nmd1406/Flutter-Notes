// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_quill/flutter_quill.dart' as quill;

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
  late quill.QuillController _contentController;
  late final List<File> _files = [...widget.note.files];
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _loadQuillState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadQuillState() {
    if (widget.note.quillState != null) {
      final doc = quill.Document.fromJson(jsonDecode(widget.note.quillState!));
      _contentController = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      _contentController = quill.QuillController.basic();
    }
  }

  void _saveEditedNote() async {
    String editedTitle = _titleController.text.trim().isEmpty
        ? 'Tiêu đề'
        : _titleController.text.trim();
    String plainText = _contentController.document.toPlainText().trim();
    String editedContent = plainText.isEmpty ? '' : plainText;
    String quillState =
        jsonEncode(_contentController.document.toDelta().toJson());
    DateTime date = DateTime.now();

    for (int i = 0; i < _files.length; ++i) {
      File savedFile = await _saveFile(_files[i]);
      _files[i] = savedFile;
    }

    ref.watch(notesProvider.notifier).saveEditedNote(
          widget.note,
          editedTitle,
          editedContent,
          quillState,
          date,
          _files,
        );

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
    final appDir = await getExternalStorageDirectory();
    final dirPath = '${appDir!.path}/${widget.note.id}';
    final newFilePath =
        '${appDir.path}/${widget.note.id}/${path.basename(file.path)}';

    final dir = Directory(dirPath);
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }

    final copiedFile = await file.copy(newFilePath);
    return copiedFile;
  }

  void _deleteFile(File file) {
    setState(() {
      _files.remove(file);
    });
  }

  List<Widget> _buildActions() {
    return [
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: TextField(
          autocorrect: false,
          focusNode: _focusNode,
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
              files: _files,
              onDeleteFile: _deleteFile,
            ),
            const SizedBox(height: 30),
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
