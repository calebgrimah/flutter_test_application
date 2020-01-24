import 'package:note_app/models/Note.dart';

abstract class DbApi {
  Stream<List<Note>> getNoteList(String uid);

  Future<Note> getSingleNote(String documentID);

  Future<bool> addSingleNote(Note note);

  void updateNote(Note note);

  void updateNoteWithTransaction(Note note);

  void deleteNote(Note note);
}
