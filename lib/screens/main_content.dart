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

  void noteLocker(WidgetRef ref) {
    final selectedNotes = ref.read(selectedNoteProvider);
    for (var note in selectedNotes) {
      ref.watch(notesProvider.notifier).toggleNoteLocker(note);
    }

    ref
        .watch(selectedNoteProvider.notifier)
        .updateSelectedNotes(selectedNotes.toList());
  }

  void notePin(WidgetRef ref) {
    final selectedNotes = ref.read(selectedNoteProvider);
    for (var note in selectedNotes) {
      ref.watch(notesProvider.notifier).toggleNotePin(note);
    }

    ref
        .watch(selectedNoteProvider.notifier)
        .updateSelectedNotes(selectedNotes.toList());
  }

  void drawerNoteFilter(List<Note> filteredNotes) {
    setState(() {
      displayingNotes = List.from(filteredNotes);
    });
  }

  void toggleSelectAllNotes() {
    final noteList =
        displayingNotes.isEmpty ? ref.read(notesProvider) : displayingNotes;
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

  @override
  Widget build(BuildContext context) {
    int selectedNotesCount = ref.watch(selectedNoteProvider).length;

    final isMultipleSelectionVisible =
        ref.watch(multipleSelectionFunctionProvider);
    final noteList = ref.watch(notesProvider);

    Widget mainContent = const Center(
      child: Text('Không có ghi chú nào ở đây'),
    );

    if (noteList.isNotEmpty) {
      if (screenTitle == 'Tất cả ghi chú') {
        mainContent = NoteList(noteList: noteList);
      } else {
        if (displayingNotes.isEmpty) {
          mainContent = const Center(
            child: Text('Trống'),
          );
        } else {
          mainContent = NoteList(noteList: displayingNotes);
        }
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
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => const SearchScreen(),
                //   ),
                // );
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
              deletedNoteCount: 0,
              onChangeNoteList: drawerNoteFilter,
              onChangeTitle: (String changedTitle) {
                screenTitle = changedTitle;
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
          ? NavigationBar(
              destinations: [
                TextButton.icon(
                  onPressed: () {
                    noteLocker(ref);
                  },
                  icon: const Icon(Icons.lock),
                  label: const Text('Khoá'),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.delete),
                  label: const Text('Xoá'),
                ),
                TextButton.icon(
                  onPressed: () {
                    notePin(ref);
                  },
                  icon: const Icon(Icons.push_pin),
                  label: const Text('Ghim'),
                )
              ],
            )
          : null,
    );
  }
}
