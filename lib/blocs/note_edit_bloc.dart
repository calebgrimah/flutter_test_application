import 'dart:async';

import 'package:note_app/models/Note.dart';
import 'package:note_app/services/db_firestore_api.dart';

class NoteEditBloc {
  final DbApi dbApi;
  final bool add;
  Note selectedNote;

  final StreamController<String> _dateController =
      StreamController<String>.broadcast();

  Sink<String> get dateEditChanged => _dateController.sink;

  Stream<String> get dateEdit => _dateController.stream;

  final StreamController<String> _titleController =
      StreamController<String>.broadcast();

  Sink<String> get moodEditChanged => _titleController.sink;

  Stream<String> get moodEdit => _titleController.stream;

  final StreamController<String> _descriptionController =
      StreamController<String>.broadcast();

  Sink<String> get noteEditChanged => _descriptionController.sink;

  Stream<String> get noteEdit => _descriptionController.stream;

  final StreamController<String> _saveNoteController =
      StreamController<String>.broadcast();

  Sink<String> get saveNoteChanged => _saveNoteController.sink;

  Stream<String> get saveNote => _saveNoteController.stream;

  NoteEditBloc(this.add, this.selectedNote, this.dbApi) {
    _startEditListeners().then((finished) => _getNote(add, selectedNote));
  }

  void dispose() {
    _dateController.close();
    _titleController.close();
    _descriptionController.close();
    _saveNoteController.close();
  }

  Future<bool> _startEditListeners() async {
    _dateController.stream.listen((date) {
      selectedNote.date = date;
    });
    _titleController.stream.listen((title) {
      selectedNote.title = title;
    });
    _descriptionController.stream.listen((desc) {
      selectedNote.description = desc;
    });
    _saveNoteController.stream.listen((action) {
      if (action == 'Save') {
        _saveNote();
      }
    });
    return true;
  }

  void _getNote(bool add, Note note) {
    if (add) {
      selectedNote = Note();
      selectedNote.date = DateTime.now().toString();
      selectedNote.title = ' ';
      selectedNote.description = '';
      selectedNote.uid = note.uid;
    } else {
      selectedNote.date = note.date;
      selectedNote.title = note.title;
      selectedNote.description = note.description;
    }
    dateEditChanged.add(selectedNote.date);
    moodEditChanged.add(selectedNote.title);
    noteEditChanged.add(selectedNote.description);
  }

  void _saveNote() {
    Note note = Note(
      documentID: selectedNote.documentID,
      date: DateTime.parse(selectedNote.date).toIso8601String(),
      title: selectedNote.title,
      description: selectedNote.description,
      uid: selectedNote.uid,
    );
    add ? dbApi.addSingleNote(note) : dbApi.updateNote(note);
  }
}
