import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Map<String, Color> colorMap = {
  'pdf': Colors.red,
  'mp4': Colors.yellow,
  'mp3': Colors.deepPurple,
  'docs': Colors.blue,
  'jpg': Colors.deepOrange,
  'png': Colors.yellow,
};

class FileGridViewItem extends StatelessWidget {
  final PlatformFile file;

  const FileGridViewItem({
    super.key,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    return const Card();
  }
}
