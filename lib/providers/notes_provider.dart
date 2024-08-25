import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:notes/models/note.dart';

class NotesNotifier extends StateNotifier<List<Note>> {
  NotesNotifier() : super([]);

  void addNewNote(String title, String content, DateTime date,
      List<PlatformFile> files, String? address) {
    Note newNote = Note(
      title: title,
      content: content,
      dateCreated: date,
      files: files,
    );

    if (address != null) {
      newNote.updateAddress(address);
    }

    state = [...state, newNote];
  }

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

  void toggleSelectedNote(Note note) {
    List<Note> notes = state;
    int index = notes.indexOf(note);
    notes[index].isSelected = !notes[index].isSelected;
    state = [...notes];
  }

  void selectNotes(List<Note> notes) {
    for (var note in notes) {
      note.isSelected = true;
    }

    state = [...notes];
  }

  void unSelectNotes(List<Note> notes) {
    for (var note in notes) {
      note.isSelected = false;
    }

    state = [...notes];
  }

  void toggleNotePin(Note note) {
    int index = state.indexOf(note);
    state[index].toggleNotePin();
    if (state[index].isPinned) {
      Note noteCopy = state[index];
      state.removeAt(index);
      state = [noteCopy, ...state];
    } else {
      Note noteCopy = state[index];
      state.removeAt(index);
      state = [...state, noteCopy];
    }
  }

  void updateUserLocation(Note note, String address) {
    int index = state.indexOf(note);
    state[index].updateAddress(address);
    state = [...state];
  }

  List<Note> getLockedNotes() {
    return state.where((note) => note.isLocked).toList();
  }

  List<Note> getDeletedNotes() {
    return state.where((note) => note.isDeleted).toList();
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>(
  (ref) => NotesNotifier(),
);
