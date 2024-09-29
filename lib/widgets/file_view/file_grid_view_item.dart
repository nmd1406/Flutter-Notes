import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;

Map<String, Color> colorMap = {
  '.pdf': Colors.red,
  '.mp4': Colors.yellow,
  '.mp3': Colors.deepPurple,
  '.docs': Colors.blue,
  '.jpg': Colors.deepOrange,
  '.png': Colors.yellow,
};

class FileGridViewItem extends StatelessWidget {
  final File file;

  const FileGridViewItem({
    super.key,
    required this.file,
  });

  void _openFile() async {
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final filePath = file.path;
    final kb = file.lengthSync() / 1024;
    final mb = kb / 1024;
    final fileSize =
        mb >= 1 ? '${mb.toStringAsFixed(2)} MB' : '${kb.toStringAsFixed(2)} KB';
    final fileExtension = path.extension(filePath);
    final fileItemColor = colorMap.containsKey(fileExtension)
        ? colorMap[fileExtension]
        : Colors.pink;
    final fileName = path
        .basename(filePath)
        .substring(0, path.basename(filePath).lastIndexOf('.'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: fileItemColor,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _openFile,
              child: Center(
                child: Text(
                  fileExtension,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          semanticsLabel: fileName,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Text(
          fileSize,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }
}
