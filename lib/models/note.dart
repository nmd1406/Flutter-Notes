import 'dart:io';

import 'package:intl/intl.dart';

final simpleFormatter = DateFormat('dd/MM/yyyy');
final detailFormatter = DateFormat('HH:ss dd/MM/yyyy');

class Note {
  String id;
  String title;
  String content;
  String? quillState;
  final DateTime dateCreated;
  DateTime? dateEdited;
  bool isLocked;
  bool isPinned;
  bool isSelected;
  bool isDeleted;
  List<File> files;
  String? address;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.quillState,
    required this.dateCreated,
    required this.files,
  })  : isLocked = false,
        isPinned = false,
        isSelected = false,
        isDeleted = false;

  Note.databaseConstructor({
    required this.id,
    required this.title,
    required this.content,
    required this.quillState,
    required this.dateCreated,
    required this.dateEdited,
    required this.files,
    required this.isLocked,
    required this.isPinned,
    required this.isSelected,
    required this.isDeleted,
  });

  String getSimpleDate(DateTime date) {
    return simpleFormatter.format(date);
  }

  String getDetailDate(DateTime date) {
    return detailFormatter.format(date);
  }

  void setNewTitle(String title) {
    this.title = title;
  }

  void setDateEdited(DateTime date) {
    dateEdited = date;
  }

  void setNewContent(String content) {
    this.content = content;
  }

  void setQuillState(String quillState) {
    this.quillState = quillState;
  }

  void toggleNoteLocker() {
    isLocked = !isLocked;
  }

  void toggleNotePin() {
    isPinned = !isPinned;
  }

  void toggleSelectedNote() {
    isSelected = !isSelected;
  }

  void updateNoteFiles(List<File> files) {
    this.files = files;
  }
}
