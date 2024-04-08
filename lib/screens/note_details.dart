import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/models/note.dart';
import 'package:notes/providers/notes_provider.dart';

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
  final _focusNode = FocusNode();

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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _saveEditedNote() {
    String editedTitle = _titleController.text.trim().isEmpty
        ? 'Không có tiêu đề'
        : _titleController.text.trim();
    String editedContent =
        _contentController.text.trim().isEmpty ? '' : _contentController.text;
    DateTime date = DateTime.now();

    ref
        .watch(notesProvider.notifier)
        .saveEditedNote(widget.note, editedTitle, editedContent, date);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 3),
        content: Text('Đã lưu thay đổi'),
      ),
    );

    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autocorrect: false,
          controller: _titleController,
          enabled: _isEditing,
          decoration: const InputDecoration(
            border: InputBorder.none,
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
      body: TextField(
        autocorrect: false,
        controller: _contentController,
        enabled: _isEditing,
        focusNode: _focusNode,
        autofocus: _isEditing,
        maxLength: 1024,
        maxLines: null,
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
