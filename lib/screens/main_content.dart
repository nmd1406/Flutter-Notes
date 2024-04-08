import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/providers/multiple_selection_function.dart';

import 'package:notes/providers/notes_provider.dart';
import 'package:notes/screens/new_note.dart';
import 'package:notes/widgets/main_drawer.dart';
import 'package:notes/widgets/note_list.dart';

class MainContentScreen extends ConsumerWidget {
  const MainContentScreen({super.key});

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
            ? Text(selectedNotesCount == 0
                ? 'Chọn ghi chú'
                : 'Đã chọn $selectedNotesCount')
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
          ]
        ],
      ),
      body: mainContent,
      drawer: const MainDrawer(),
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
          ? NavigationBar(destinations: [
              IconButton(onPressed: () {}, icon: Icon(Icons.abc)),
              Container()
            ])
          : null,
    );
  }
}
