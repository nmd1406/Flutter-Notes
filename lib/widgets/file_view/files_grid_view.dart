import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/providers/notes_provider.dart';
import 'package:notes/widgets/file_view/file_grid_view_item.dart';

class FileGridView extends ConsumerWidget {
  final List<File> files;
  final void Function(File file) onDeleteFile;

  const FileGridView({
    super.key,
    required this.files,
    required this.onDeleteFile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(notesProvider);

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      shrinkWrap: true,
      itemCount: files.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 23,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) => Stack(
        children: [
          FileGridViewItem(
            file: files[index],
          ),
          CloseButton(
            onPressed: () {
              onDeleteFile(files[index]);
            },
          ),
        ],
      ),
    );
  }
}
