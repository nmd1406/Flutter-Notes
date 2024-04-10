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
}
