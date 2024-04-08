import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();
final simpleFormatter = DateFormat('dd/MM/yyyy');
final detailFormatter = DateFormat('HH:ss dd/MM/yyyy');

class Note {
  final String id;
  String title;
  String content;
  final DateTime dateCreated;
  DateTime? dateEdited;

  Note({
    required this.title,
    required this.content,
    required this.dateCreated,
  }) : id = uuid.v4();

  String getCreatedDate() {
    return simpleFormatter.format(dateCreated);
  }

  String getEditedDate() {
    return detailFormatter.format(dateEdited!);
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
}
