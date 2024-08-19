import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/providers/multiple_selection_function.dart';

import 'package:notes/providers/notes_provider.dart';
import 'package:notes/screens/new_note.dart';
import 'package:notes/widgets/main_drawer.dart';
import 'package:notes/widgets/notes_views/note_list.dart';

class MainContentScreen extends ConsumerWidget {
  const MainContentScreen({super.key});

  void _noteLocker(WidgetRef ref) {
    final selectedNotes = ref.read(selectedNoteProvider);
    for (var note in selectedNotes) {
      ref.watch(notesProvider.notifier).toggleNoteLocker(note);
    }

    ref.watch(selectedNoteProvider.notifier).updateSelectedNotes(selectedNotes);
  }

  void _notePin(WidgetRef ref) {
    final selectedNotes = ref.read(selectedNoteProvider);
    for (var note in selectedNotes) {
      ref.watch(notesProvider.notifier).toggleNotePin(note);
    }

    ref.watch(selectedNoteProvider.notifier).updateSelectedNotes(selectedNotes);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMultipleSelectionVisible =
        ref.watch(multipleSelectionFunctionProvider);
    final noteList = ref.watch(notesProvider);
    int selectedNotesCount = ref.watch(selectedNotesCountProvider);
    Widget mainContent = const Center(
      child: Text('Không có ghi chú'),
    );

    if (noteList.isNotEmpty) {
      mainContent = NoteList(
        noteList: noteList,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: isMultipleSelectionVisible
            ? Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {},
                    icon: Icon(Icons.circle_outlined),
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
                'Tất cả ghi chú',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
        actions: [
          if (!isMultipleSelectionVisible) ...[
            IconButton(
              tooltip: 'Tìm kiếm',
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
            PopupMenuButton(
              tooltip: 'Tuỳ chọn khác',
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Sửa'),
                  onTap: () {},
                ),
                PopupMenuItem(
                  child: const Text('Xem'),
                  onTap: () {},
                ),
                PopupMenuItem(
                  child: const Text('Ghim mục yêu thích lên đầu'),
                  onTap: () {},
                ),
              ],
            ),
          ] else ...[
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.close),
            ),
          ]
        ],
      ),
      body: mainContent,
      drawer: isMultipleSelectionVisible ? null : const MainDrawer(),
      floatingActionButton: Visibility(
        visible: !isMultipleSelectionVisible,
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
                    _noteLocker(ref);
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
                    _notePin(ref);
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
