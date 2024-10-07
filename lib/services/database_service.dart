import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:notes/models/note.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String _tableName = 'note';
  final String _idColumn = 'id';
  final String _titleColumn = 'title';
  final String _contentColumn = 'content';
  final String _quillStateColumn = 'quillState';
  final String _dateCreatedColumn = 'dateCreated';
  final String _dateEditedColumn = 'dateEdited';
  final String _dataDeletedColumn = 'dateDeleted';
  final String _isLockedColumn = 'isLocked';
  final String _isPinnedColumn = 'isPinned';
  final String _isSelectedColumn = 'isSelected';
  final String _isDeletedColumn = 'isDeleted';
  final String _filePathsColumn = 'filePaths';

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "note_db.db");
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          create table if not exists $_tableName (
            $_idColumn text primary key,
            $_titleColumn text,
            $_contentColumn text,
            $_quillStateColumn text,
            $_dateCreatedColumn text,
            $_dateEditedColumn text,
            $_dataDeletedColumn text,
            $_isLockedColumn integer,
            $_isPinnedColumn integer,
            $_isSelectedColumn integer,
            $_isDeletedColumn integer,
            $_filePathsColumn text
          )
        ''');
      },
    );

    return database;
  }

  String getFilePaths(Note note) {
    String filePaths = '';
    if (note.files.isNotEmpty) {
      StringBuffer buffer = StringBuffer(filePaths);
      buffer.writeAll(note.files.map((file) => file.path).toList(), ',');
      filePaths = buffer.toString();
    }

    return filePaths;
  }

  void addNewNote(Note note) async {
    final db = await database;
    String filePaths = getFilePaths(note);

    await db.insert(
      _tableName,
      {
        _idColumn: note.id,
        _titleColumn: note.title,
        _contentColumn: note.content,
        _quillStateColumn: note.quillState,
        _dateCreatedColumn: note.dateCreated.toString(),
        _dateEditedColumn: '',
        _isLockedColumn: 0,
        _isPinnedColumn: 0,
        _isSelectedColumn: 0,
        _isDeletedColumn: 0,
        _filePathsColumn: filePaths,
      },
    );
  }

  void updateNote(Note note) async {
    final db = await database;
    String filePaths = getFilePaths(note);
    await db.update(
      _tableName,
      {
        _titleColumn: note.title,
        _contentColumn: note.content,
        _quillStateColumn: note.quillState,
        _dateEditedColumn: note.dateEdited.toString(),
        _isLockedColumn: note.isLocked ? 1 : 0,
        _isPinnedColumn: note.isPinned ? 1 : 0,
        _isSelectedColumn: note.isSelected ? 1 : 0,
        _isDeletedColumn: note.isDeleted ? 1 : 0,
        _filePathsColumn: filePaths,
      },
      where: '$_idColumn = ?',
      whereArgs: [note.id],
    );
  }

  void deleteNote(Note note) async {
    final db = await database;

    DateTime dateDeleted = DateTime.now();
    await db.update(
      _tableName,
      {
        _dataDeletedColumn: dateDeleted.toString(),
      },
    );
    await db.delete(
      _tableName,
      where: '$_idColumn = ?',
      whereArgs: [note.id],
    );
  }

  void monthlyCleanUpNotes() async {
    final db = await database;

    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    await db.delete(
      _tableName,
      where: '$_dataDeletedColumn < ?',
      whereArgs: [thirtyDaysAgo.toString()],
    );
  }

  void emptyTable() async {
    final db = await database;
    await db.delete(_tableName);
  }

  void deleteDb() async {
    String path = join(await getDatabasesPath(), "note_db.db");
    await deleteDatabase(path);
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final data = await db.query(_tableName);
    List<Note> notes = data.map((note) {
      List<String> filePaths = [];
      List<File> files = [];
      if ((note[_filePathsColumn] as String).isNotEmpty) {
        filePaths = (note[_filePathsColumn] as String).split(',');
        files = filePaths.map((path) => File(path)).toList();
      }
      return Note.databaseConstructor(
        id: note[_idColumn] as String,
        title: note[_titleColumn] as String,
        content: note[_contentColumn] as String,
        quillState: note[_quillStateColumn] as String,
        dateCreated: DateTime.parse(note[_dateCreatedColumn] as String),
        dateEdited: (note[_dateEditedColumn] as String).isEmpty
            ? null
            : DateTime.parse(note[_dateEditedColumn] as String),
        files: files,
        isLocked: (note[_isLockedColumn] as int) == 1 ? true : false,
        isPinned: (note[_isPinnedColumn] as int) == 1 ? true : false,
        isSelected: (note[_isSelectedColumn] as int) == 1 ? true : false,
        isDeleted: (note[_isDeletedColumn] as int) == 1 ? true : false,
      );
    }).toList();

    return notes;
  }
}
