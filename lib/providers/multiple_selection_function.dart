import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/models/note.dart';

class MultipleSelectionFunctionNotifier extends StateNotifier<bool> {
  MultipleSelectionFunctionNotifier() : super(false);

  void toggle(bool isVisible) {
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
    state = [...notes];
  }

  void deleteAllSelectedNote() {
    state = [];
  }

  void addSelectedNote(Note note) {
    state = [...state, note];
  }

  void removeSelectedNote(Note note) {
    state.remove(note);
    state = [...state];
  }

  int count() {
    return state.length;
  }
}

final selectedNoteProvider =
    StateNotifierProvider<SelectedNoteNotifier, List<Note>>(
        (ref) => SelectedNoteNotifier());
