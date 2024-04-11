import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/models/note.dart';

class MultipleSelectionFunctionNotifier extends StateNotifier<bool> {
  MultipleSelectionFunctionNotifier() : super(false);

  void showScreen(bool isVisible) {
    state = isVisible;
  }
}

final multipleSelectionFunctionProvider =
    StateNotifierProvider<MultipleSelectionFunctionNotifier, bool>(
  (ref) => MultipleSelectionFunctionNotifier(),
);

class SelectedNoteNotifier extends StateNotifier<List<Note>> {
  SelectedNoteNotifier() : super([]);

  void updateSelectedNotes(List<Note> notes) {
    state = notes;
  }
}

final selectedNoteProvider =
    StateNotifierProvider<SelectedNoteNotifier, List<Note>>(
        (ref) => SelectedNoteNotifier());

class SelectedNotesCountNotifier extends StateNotifier<int> {
  SelectedNotesCountNotifier() : super(0);

  void update(int count) {
    state = count;
  }
}

final selectedNotesCountProvider =
    StateNotifierProvider<SelectedNotesCountNotifier, int>(
        (ref) => SelectedNotesCountNotifier());
