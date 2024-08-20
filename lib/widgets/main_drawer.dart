import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:notes/models/note.dart';
import 'package:notes/providers/notes_provider.dart';

class MainDrawer extends ConsumerWidget {
  final int noteCount;
  final int lockedNoteCount;
  final int deletedNoteCount;
  final void Function(List<Note> filteredNotes) onChangeNoteList;

  const MainDrawer({
    super.key,
    required this.noteCount,
    required this.lockedNoteCount,
    required this.deletedNoteCount,
    required this.onChangeNoteList,
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
                title: const Text('Tất cả ghi chú'),
                trailing: Text('$noteCount'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onTap: () {
                  onChangeNoteList(allNotes);
                },
              ),
              const SizedBox(
                height: 6,
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Ghi chú bị khoá'),
                trailing: Text('$lockedNoteCount'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onTap: () {
                  final deletedNotes =
                      allNotes.where((note) => note.isLocked).toList();
                  onChangeNoteList(deletedNotes);
                },
              ),
              const SizedBox(
                height: 6,
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Thùng rác'),
                trailing: Text('$deletedNoteCount'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onTap: () {
                  final deletedNotes =
                      allNotes.where((note) => note.isDeleted).toList();
                  onChangeNoteList(deletedNotes);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
