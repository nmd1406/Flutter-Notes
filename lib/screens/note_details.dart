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
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  late final List<File> _files = [...widget.note.files];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
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

  List<Widget> _buildActions() {
    if (_isSearching) {
      return [
        CloseButton(
          onPressed: () {
            setState(() {
              FocusManager.instance.primaryFocus?.unfocus();
              _isSearching = false;
              _searchController.clear();
            });
          },
        )
      ];
    }

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
      IconButton(
        tooltip: 'Tìm kiếm',
        onPressed: () {
          setState(() {
            _isSearching = true;
          });
        },
        icon: const Icon(Icons.search),
      ),
    ];
  }

  Widget _buildHighlightedText() {
    String text = _contentController.text;
    if (_searchQuery.isEmpty) {
      return TextField(
        autocorrect: false,
        controller: _contentController,
        textCapitalization: TextCapitalization.sentences,
        maxLength: 1024,
        maxLines: null,
        cursorColor: Colors.red,
        buildCounter: (
          context, {
          int? currentLength,
          bool? isFocused,
          int? maxLength,
        }) =>
            null,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
          hintText: 'Ghi chú ở đây...',
        ),
      );
    }

    List<TextSpan> spans = _getHighlightedTextSpans(text, _searchQuery);
    return Container(
      padding: const EdgeInsets.all(15),
      child: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          children: spans,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  List<TextSpan> _getHighlightedTextSpans(String text, String query) {
    List<TextSpan> spans = [];
    int start = 0;

    while (true) {
      final startIndex = text.toLowerCase().indexOf(query.toLowerCase(), start);

      // If no more matches found, add the rest of the text
      if (startIndex == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      // Add the text before the match
      if (startIndex > start) {
        spans.add(TextSpan(text: text.substring(start, startIndex)));
      }

      // Add the matched text (highlighted)
      spans.add(
        TextSpan(
          text: text.substring(startIndex, startIndex + query.length),
          style: const TextStyle(backgroundColor: Colors.yellow),
        ),
      );

      // Update the start position
      start = startIndex + query.length;
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TapRegion(
                onTapOutside: (event) {
                  setState(() {
                    FocusManager.instance.primaryFocus?.unfocus();
                    _isSearching = false;
                    _searchController.clear();
                  });
                },
                child: TextField(
                  controller: _searchController,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'Nhập từ khoá',
                    border: InputBorder.none,
                  ),
                ),
              )
            : TextField(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHighlightedText(),
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
