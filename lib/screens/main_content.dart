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
  List<Note> displayingNotes = [];
  bool isSelectAll = false;
  String screenTitle = 'Tất cả ghi chú';

  void noteLocker() {
    final selectedNotes = ref.read(selectedNoteProvider);
    for (var note in selectedNotes) {
      ref.watch(notesProvider.notifier).toggleNoteLocker(note);
    }

    ref.watch(selectedNoteProvider.notifier).updateSelectedNotes(selectedNotes);

    final lockedNotes = ref.watch(notesProvider.notifier).getLockedNotes();
    ref.read(lockedNoteProvider.notifier).update(lockedNotes);
  }

  void notePin() {
    final selectedNotes = ref.read(selectedNoteProvider);
    for (var note in selectedNotes) {
      ref.watch(notesProvider.notifier).toggleNotePin(note);
    }
  }

  void toggleSelectAllNotes() {
    List<Note> noteList = [];
    if (screenTitle == 'Tất cả ghi chú') {
      noteList = ref.read(notesProvider);
    } else if (screenTitle == 'Ghi chú bị khoá') {
      noteList = ref.read(lockedNoteProvider);
    } else {
      ref.read(deletedNoteProvider);
    }

    final selectedNotes = ref.read(selectedNoteProvider);

    if (noteList.length == selectedNotes.length) {
      ref.watch(selectedNoteProvider.notifier).deleteAllSelectedNote();
      ref.watch(notesProvider.notifier).unSelectNotes(noteList);
      setState(() {
        isSelectAll = false;
      });
    } else {
      ref.watch(selectedNoteProvider.notifier).updateSelectedNotes(noteList);
      ref.watch(notesProvider.notifier).selectNotes(noteList);
      setState(() {
        isSelectAll = true;
      });
    }
  }

  void turnOffMultiSelectNote() {
    ref.watch(multipleSelectionFunctionProvider.notifier).toggle(false);
    setState(() {
      isSelectAll = false;
    });
  }

  void moveNoteToBin() {
    final selectedNotes = ref.read(selectedNoteProvider);
    for (var note in selectedNotes) {
      ref.watch(notesProvider.notifier).moveNoteToBin(note);
      ref.watch(deletedNoteProvider.notifier).update(note);
    }
    // final deletedNotes = ref.watch(notesProvider.notifier).getDeletedNotes();
  }

  void restoreNote() {
    final selectedNotes = ref.read(selectedNoteProvider);
    for (var note in selectedNotes) {
      ref.watch(notesProvider.notifier).restoreNote(note);
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

    if (screenTitle == 'Tất cả ghi chú') {
      if (noteList.isEmpty) {
        mainContent = const Center(
          child: Text('Không có ghi chú nào ở đây'),
        );
      }
    } else if (screenTitle == 'Ghi chú bị khoá') {
      if (lockedNotes.isEmpty) {
        mainContent = const Center(
          child: Text('Không có ghi chú nào ở đây'),
        );
      } else {
        mainContent = NoteList(noteList: lockedNotes);
      }
    } else if (screenTitle == 'Thùng rác') {
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
                      toggleSelectAllNotes();
                    },
                    icon: !isSelectAll
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
                screenTitle,
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
                  isSelectAll = false;
                });
              },
              icon: const Icon(Icons.close),
            ),
          ]
        ],
      ),
      body: mainContent,
      drawer: isMultipleSelectionVisible
          ? null
          : MainDrawer(
              noteCount: noteList.length,
              lockedNoteCount: noteList.where((note) => note.isLocked).length,
              deletedNoteCount: deletedNotes.length,
              onChangeTitle: (String changedTitle) {
                setState(() {
                  screenTitle = changedTitle;
                });
              },
            ),
      floatingActionButton: Visibility(
        visible: !isMultipleSelectionVisible && screenTitle == 'Tất cả ghi chú',
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
                  if (screenTitle != 'Thùng rác')
                    TextButton.icon(
                      onPressed: () {
                        noteLocker();
                        turnOffMultiSelectNote();
                      },
                      icon: const Icon(Icons.lock),
                      label: Text(
                        screenTitle == 'Tất cả ghi chú' ? 'Khoá' : 'Mở khoá',
                      ),
                    ),
                  if (screenTitle != 'Ghi chú bị khoá')
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
                                  moveNoteToBin();
                                  turnOffMultiSelectNote();
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
                        screenTitle == 'Thùng rác' ? 'Xoá vĩnh viễn' : 'Xoá',
                      ),
                    ),
                  if (screenTitle == 'Thùng rác')
                    TextButton.icon(
                      onPressed: () {
                        restoreNote();
                        turnOffMultiSelectNote();
                      },
                      icon: const Icon(Icons.restore_from_trash_rounded),
                      label: const Text('Khôi phục'),
                    ),
                  if (screenTitle == 'Tất cả ghi chú')
                    TextButton.icon(
                      onPressed: () {
                        notePin();
                        turnOffMultiSelectNote();
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
