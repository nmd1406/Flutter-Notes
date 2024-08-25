import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:notes/models/note.dart';
import 'package:notes/providers/notes_provider.dart';

class MainDrawer extends ConsumerWidget {
  final int noteCount;
  final int lockedNoteCount;
  final int deletedNoteCount;
  final void Function(List<Note> filteredNotes) onChangeNoteList;
  final void Function(String changedTitle) onChangeTitle;

  const MainDrawer({
    super.key,
    required this.noteCount,
    required this.lockedNoteCount,
    required this.deletedNoteCount,
    required this.onChangeNoteList,
    required this.onChangeTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allNotes = ref.watch(notesProvider);

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.82,
      child: Drawer(
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: DrawerHeader(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Image.asset("assets/images/unnamed.png"),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              ListTile(
                leading: const Icon(Icons.text_snippet),
                title: const Text(
                  'Tất cả ghi chú',
                  style: TextStyle(fontSize: 20),
                ),
                trailing: Text(
                  '$noteCount',
                  style: const TextStyle(fontSize: 14),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onTap: () {
                  onChangeNoteList(allNotes);
                  onChangeTitle('Tất cả ghi chú');
                  if (Scaffold.of(context).isDrawerOpen) {
                    Scaffold.of(context).closeDrawer();
                  }
                },
              ),
              const SizedBox(
                height: 6,
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text(
                  'Ghi chú bị khoá',
                  style: TextStyle(fontSize: 20),
                ),
                trailing: Text(
                  '$lockedNoteCount',
                  style: const TextStyle(fontSize: 14),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onTap: () {
                  final deletedNotes =
                      allNotes.where((note) => note.isLocked).toList();
                  onChangeNoteList(deletedNotes);
                  onChangeTitle('Ghi chú bị khoá');
                  if (Scaffold.of(context).isDrawerOpen) {
                    Scaffold.of(context).closeDrawer();
                  }
                },
              ),
              const SizedBox(
                height: 6,
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text(
                  'Thùng rác',
                  style: TextStyle(fontSize: 20),
                ),
                trailing: Text(
                  '$deletedNoteCount',
                  style: const TextStyle(fontSize: 14),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onTap: () {
                  final deletedNotes =
                      allNotes.where((note) => note.isDeleted).toList();
                  onChangeNoteList(deletedNotes);
                  onChangeTitle('Thùng rác');
                  if (Scaffold.of(context).isDrawerOpen) {
                    Scaffold.of(context).closeDrawer();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
