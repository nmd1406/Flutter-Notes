import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FileProvider extends StateNotifier<List<PlatformFile>> {
  FileProvider() : super([]);

  void update(List<PlatformFile> fileList) {
    state = [...state, ...fileList];
  }
}

final fileProviderNotifier =
    StateNotifierProvider<FileProvider, List<PlatformFile>>(
  (ref) => FileProvider(),
);
