import 'dart:async';

import 'package:note_app/models/Note.dart';
import 'package:note_app/services/authentication_api.dart';
import 'package:note_app/services/db_firestore_api.dart';

class HomeBloc {
  final DbApi dbApi;
  final AuthenticationApi authenticationApi;

  final StreamController<List<Note>> _noteController =
      StreamController<List<Note>>.broadcast();

  Sink<List<Note>> get _addListNote => _noteController.sink;

  Stream<List<Note>> get listNote => _noteController.stream;

  final StreamController<Note> _noteDeleteController =
      StreamController<Note>.broadcast();

  Sink<Note> get deleteNote => _noteDeleteController.sink;

  HomeBloc(this.dbApi, this.authenticationApi) {
    _startListeners();
  }

  void dispose() {
    if (!_noteController.hasListener) {
      _noteController.close();
      _noteDeleteController.close();
    }
  }

  void _startListeners() {
    // Retrieve Firestore Journal Records as List<Journal> not DocumentSnapshot
    authenticationApi.getFirebaseAuth().currentUser().then((user) {
      dbApi.getNoteList(user.uid).listen((journalDocs) {
        _addListNote.add(journalDocs);
      });

      _noteDeleteController.stream.listen((journal) {
        dbApi.deleteNote(journal);
      });
    });
  }
}
