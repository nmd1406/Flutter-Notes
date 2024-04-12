import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditStateProvider extends StateNotifier<bool> {
  EditStateProvider() : super(false);

  void update(bool value) {
    state = value;
  }
}

final editStateNotifier = StateNotifierProvider<EditStateProvider, bool>(
    (ref) => EditStateProvider());
