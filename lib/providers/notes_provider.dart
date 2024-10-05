import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/models/note.dart';
import 'package:notes/services/database_service.dart';

final DatabaseService _databaseService = DatabaseService.instance;

class NotesNotifier extends StateNotifier<List<Note>> {
  NotesNotifier() : super([]);

  Future<void> loadNotes() async {
    // _databaseService.deleteDb();
    state = await _databaseService.getNotes();
  }

  void addNewNote(Note newNote, List<File> files) {
    print('add new note');
    _databaseService.addNewNote(newNote);
    state = [...state, newNote];
    int index = state.indexOf(newNote);
    print(state[index].files.length);
  }

  void saveEditedNote(Note note, String title, String content,
      String quillState, DateTime dateEdited, List<File> files) {
    List<Note> notes = state;
    int index = notes.indexOf(note);
    notes[index].setNewContent(content);
    notes[index].setQuillState(quillState);
    notes[index].setNewTitle(title);
    notes[index].setDateEdited(dateEdited);

    notes[index].updateNoteFiles(files);

    _databaseService.updateNote(note);
    state = [...notes];
  }

  void toggleNoteLocker(Note note) {
    List<Note> notes = state;
    int index = notes.indexOf(note);
    notes[index].toggleNoteLocker();

    _databaseService.updateNote(note);
    state = [...notes];
  }

  void toggleSelectedNote(Note note) {
    List<Note> notes = state;
    int index = notes.indexOf(note);
    notes[index].isSelected = !notes[index].isSelected;

    _databaseService.updateNote(note);
    state = [...notes];
  }

  void selectNotes(List<Note> notes) {
    for (var note in notes) {
      int index = state.indexOf(note);
      state[index].isSelected = true;
      _databaseService.updateNote(state[index]);
    }

    state = [...state];
  }

  void unSelectNotes(List<Note> notes) {
    for (var note in notes) {
      int index = state.indexOf(note);
      state[index].isSelected = false;
      _databaseService.updateNote(state[index]);
    }

    state = [...state];
  }

  void toggleNotePin(Note note) {
    int index = state.indexOf(note);
    state[index].toggleNotePin();
    _databaseService.updateNote(state[index]);
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

  List<Note> getLockedNotes() {
    return state.where((note) => note.isLocked).toList();
  }

  List<Note> getDeletedNotes() {
    return state.where((note) => note.isDeleted).toList();
  }

  void moveNoteToBin(Note note) {
    int index = state.indexOf(note);
    state[index].isDeleted = true;
    state[index].isPinned = false;
    state[index].isLocked = false;

    _databaseService.updateNote(state[index]);
    state = [...state];
  }

  void restoreNote(Note note) {
    int index = state.indexOf(note);
    state[index].isDeleted = false;

    _databaseService.updateNote(state[index]);
    state = [...state];
  }

  void deletePermanently(Note note) {
    int index = state.indexOf(note);
    state.removeAt(index);
    _databaseService.deleteNote(note);
    state = [...state];
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>(
  (ref) => NotesNotifier(),
);

class LockedNoteNotifier extends StateNotifier<List<Note>> {
  LockedNoteNotifier() : super([]);

  void update(List<Note> noteList) {
    state = [...noteList];
  }
}

final lockedNoteProvider =
    StateNotifierProvider<LockedNoteNotifier, List<Note>>(
  (ref) => LockedNoteNotifier(),
);

class DeletedNoteNotifier extends StateNotifier<List<Note>> {
  DeletedNoteNotifier() : super([]);

  void update(Note note) {
    state = [...state, note];
  }

  void delete(Note note) {
    state.remove(note);
    state = [...state];
  }
}

final deletedNoteProvider =
    StateNotifierProvider<DeletedNoteNotifier, List<Note>>(
  (ref) => DeletedNoteNotifier(),
);
