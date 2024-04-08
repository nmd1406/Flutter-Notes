import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/models/note.dart';

class NotesNotifier extends StateNotifier<List<Note>> {
  NotesNotifier() : super([]);

  void addNewNote(String title, String content, DateTime date) {
    Note newNote = Note(
      title: title,
      content: content,
      dateCreated: date,
    );
    state = [...state, newNote];
  }

  void saveEditedNote(
      Note note, String title, String content, DateTime dateEdited) {
    List<Note> notes = state;
    int index = notes.indexOf(note);
    notes[index].setNewContent(content);
    notes[index].setNewTitle(title);
    notes[index].setDateEdited(dateEdited);
    state = [...notes];
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>(
  (ref) => NotesNotifier(),
);
