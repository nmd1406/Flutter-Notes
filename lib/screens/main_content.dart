import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/models/note.dart';

import 'package:notes/providers/multiple_selection_function.dart';
import 'package:notes/providers/notes_provider.dart';
import 'package:notes/screens/new_note.dart';
import 'package:notes/screens/search_screen.dart';
import 'package:notes/widgets/main_drawer.dart';
import 'package:notes/widgets/notes_views/note_list.dart';

class MainContentScreen extends ConsumerStatefulWidget {
  const MainContentScreen({super.key});

  @override
  ConsumerState<MainContentScreen> createState() => _MainContentScreenState();
}

class _MainContentScreenState extends ConsumerState<MainContentScreen> {
  bool _isSelectAll = false;
  String _screenTitle = 'Tất cả ghi chú';
  late Future<void> _notesFuture;

  @override
  void initState() {
    super.initState();
    _notesFuture = ref.read(notesProvider.notifier).loadNotes();
  }

  void _noteLocker() {
    final selectedNotes = ref.read(selectedNoteProvider);
    for (var note in selectedNotes) {
      ref.watch(notesProvider.notifier).toggleNoteLocker(note);
    }

    ref.watch(selectedNoteProvider.notifier).updateSelectedNotes(selectedNotes);

    final lockedNotes = ref.watch(notesProvider.notifier).getLockedNotes();
    ref.read(lockedNoteProvider.notifier).update(lockedNotes);
  }

  void _notePin() {
    final selectedNotes = ref.read(selectedNoteProvider);
    for (var note in selectedNotes) {
      ref.watch(notesProvider.notifier).toggleNotePin(note);
    }
  }

  void _toggleSelectAllNotes() {
    List<Note> noteList = [];
    if (_screenTitle == 'Tất cả ghi chú') {
      noteList = ref.read(notesProvider);
    } else if (_screenTitle == 'Ghi chú bị khoá') {
      noteList = ref.read(lockedNoteProvider);
    } else {
      ref.read(deletedNoteProvider);
    }

    final selectedNotes = ref.read(selectedNoteProvider);

    if (noteList.length == selectedNotes.length) {
      ref.watch(selectedNoteProvider.notifier).deleteAllSelectedNote();
      ref.watch(notesProvider.notifier).unSelectNotes(noteList);
      setState(() {
        _isSelectAll = false;
      });
    } else {
      ref.watch(selectedNoteProvider.notifier).updateSelectedNotes(noteList);
      ref.watch(notesProvider.notifier).selectNotes(noteList);
      setState(() {
        _isSelectAll = true;
      });
    }
  }

  void _turnOffMultiSelectNote() {
    ref.watch(multipleSelectionFunctionProvider.notifier).toggle(false);
    setState(() {
      _isSelectAll = false;
    });
  }

  void _moveNoteToBin() {
    final selectedNotes = ref.read(selectedNoteProvider);
    for (var note in selectedNotes) {
      ref.watch(notesProvider.notifier).moveNoteToBin(note);
      ref.watch(deletedNoteProvider.notifier).update(note);
    }
  }

  void _restoreNote() {
    final selectedNotes = ref.read(selectedNoteProvider);
    for (var note in selectedNotes) {
      ref.watch(notesProvider.notifier).restoreNote(note);
      ref.watch(deletedNoteProvider.notifier).delete(note);
    }
  }

  void _deletePermanently() {
    final selectedNotes = ref.read(selectedNoteProvider);
    for (var note in selectedNotes) {
      ref.watch(notesProvider.notifier).deletePermanently(note);
      ref.watch(deletedNoteProvider.notifier).delete(note);
    }
  }

  @override
  Widget build(BuildContext context) {
    int selectedNotesCount = ref.watch(selectedNoteProvider).length;

    final isMultipleSelectionVisible =
        ref.watch(multipleSelectionFunctionProvider);
    final noteList =
        ref.watch(notesProvider).where((note) => !note.isDeleted).toList();
    final lockedNotes = ref.watch(lockedNoteProvider);
    final deletedNotes = ref.watch(deletedNoteProvider);

    Widget mainContent = NoteList(noteList: noteList);

    if (_screenTitle == 'Tất cả ghi chú') {
      if (noteList.isEmpty) {
        mainContent = const Center(
          child: Text('Không có ghi chú nào ở đây'),
        );
      }
    } else if (_screenTitle == 'Ghi chú bị khoá') {
      if (lockedNotes.isEmpty) {
        mainContent = const Center(
          child: Text('Không có ghi chú nào ở đây'),
        );
      } else {
        mainContent = NoteList(noteList: lockedNotes);
      }
    } else if (_screenTitle == 'Thùng rác') {
      if (deletedNotes.isEmpty) {
        mainContent = const Center(
          child: Text('Không có ghi chú nào ở đây'),
        );
      } else {
        mainContent = NoteList(noteList: deletedNotes);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: isMultipleSelectionVisible
            ? Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      _toggleSelectAllNotes();
                    },
                    icon: !_isSelectAll
                        ? const Icon(Icons.circle_outlined)
                        : const Icon(
                            Icons.check_circle,
                            color: Colors.red,
                          ),
                  ),
                  Text(
                    selectedNotesCount == 0
                        ? 'Chọn ghi chú'
                        : 'Đã chọn $selectedNotesCount',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              )
            : Text(
                _screenTitle,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
        actions: [
          if (!isMultipleSelectionVisible) ...[
            IconButton(
              tooltip: 'Tìm kiếm',
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: SearchScreen(noteList),
                );
              },
              icon: const Icon(Icons.search),
            ),
          ] else ...[
            IconButton(
              onPressed: () {
                ref
                    .watch(multipleSelectionFunctionProvider.notifier)
                    .toggle(false);
                setState(() {
                  _isSelectAll = false;
                });
              },
              icon: const Icon(Icons.close),
            ),
          ]
        ],
      ),
      body: FutureBuilder(
        future: _notesFuture,
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : mainContent,
      ),
      drawer: isMultipleSelectionVisible
          ? null
          : MainDrawer(
              noteCount: noteList.length,
              lockedNoteCount: noteList.where((note) => note.isLocked).length,
              deletedNoteCount: deletedNotes.length,
              onChangeTitle: (String changedTitle) {
                setState(() {
                  _screenTitle = changedTitle;
                });
              },
            ),
      floatingActionButton: Visibility(
        visible:
            !isMultipleSelectionVisible && _screenTitle == 'Tất cả ghi chú',
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NewNoteScreen(),
              ),
            );
          },
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.note_add_sharp,
            color: Colors.red,
          ),
        ),
      ),
      bottomNavigationBar: isMultipleSelectionVisible && selectedNotesCount > 0
          ? Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      spreadRadius: 7.4,
                      blurRadius: 11,
                    )
                  ]),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (_screenTitle != 'Thùng rác')
                    TextButton.icon(
                      onPressed: () {
                        _noteLocker();
                        _turnOffMultiSelectNote();
                      },
                      icon: const Icon(Icons.lock),
                      label: Text(
                        _screenTitle == 'Tất cả ghi chú' ? 'Khoá' : 'Mở khoá',
                      ),
                    ),
                  if (_screenTitle != 'Ghi chú bị khoá')
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Xác nhận'),
                            content: const Text(
                                'Ghi chú sẽ được đưa vào thùng rác và sẽ bị xoá vĩnh viễn sau 30 ngày.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  if (_screenTitle != 'Thùng rác') {
                                    _moveNoteToBin();
                                  } else {
                                    _deletePermanently();
                                  }
                                  _turnOffMultiSelectNote();
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Huỷ'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete),
                      label: Text(
                        _screenTitle == 'Thùng rác' ? 'Xoá vĩnh viễn' : 'Xoá',
                      ),
                    ),
                  if (_screenTitle == 'Thùng rác')
                    TextButton.icon(
                      onPressed: () {
                        _restoreNote();
                        _turnOffMultiSelectNote();
                      },
                      icon: const Icon(Icons.restore_from_trash_rounded),
                      label: const Text('Khôi phục'),
                    ),
                  if (_screenTitle == 'Tất cả ghi chú')
                    TextButton.icon(
                      onPressed: () {
                        _notePin();
                        _turnOffMultiSelectNote();
                      },
                      icon: const Icon(Icons.push_pin),
                      label: const Text('Ghim'),
                    )
                ],
              ),
            )
          : null,
    );
  }
}
