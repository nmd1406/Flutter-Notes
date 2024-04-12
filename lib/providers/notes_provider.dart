import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:notes/models/note.dart';

class NotesNotifier extends StateNotifier<List<Note>> {
  NotesNotifier() : super([]);

  void addNewNote(
      String title, String content, DateTime date, List<PlatformFile> files) {
    Note newNote = Note(
      title: title,
      content: content,
      dateCreated: date,
      files: files,
    );
    state = [...state, newNote];
  }

  // void updateNoteFiles(Note note, List<PlatformFile> files) {
  //   List<Note> notes = state;
  //   int index = notes.indexOf(note);
  //   notes[index].updateNoteFiles(files);
  //   state = [...notes];
  // }

  void saveEditedNote(Note note, String title, String content,
      DateTime dateEdited, List<PlatformFile> files) {
    List<Note> notes = state;
    int index = notes.indexOf(note);
    notes[index].setNewContent(content);
    notes[index].setNewTitle(title);
    notes[index].setDateEdited(dateEdited);
    notes[index].updateNoteFiles(files);

    state = [...notes];
  }

  void toggleNoteLocker(Note note) {
    List<Note> notes = state;
    int index = notes.indexOf(note);
    notes[index].toggleNoteLocker();
    state = [...notes];
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>(
  (ref) => NotesNotifier(),
);
