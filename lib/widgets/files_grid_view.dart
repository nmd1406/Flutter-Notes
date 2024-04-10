import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:notes/widgets/file_grid_view_item.dart';

class FileGridView extends StatelessWidget {
  final List<PlatformFile> files;

  const FileGridView({
    required this.files,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: files.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) => FileGridViewItem(
        file: files[index],
      ),
    );
  }
}
