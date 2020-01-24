import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_app/models/Note.dart';

import 'db_firestore_api.dart';

class DbFirestoreService implements DbApi {
  final Firestore _firestore = Firestore.instance;
  final String _collectionNotes = 'notes';

  DbFirestoreService() {
    _firestore.settings();
  }

  Stream<List<Note>> getNoteList(String uid) {
    return _firestore
        .collection(_collectionNotes)
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((QuerySnapshot snapshot) {
      List<Note> _journalDocs =
          snapshot.documents.map((doc) => Note.fromDoc(doc)).toList();
      _journalDocs.sort((comp1, comp2) => comp2.date.compareTo(comp1.date));
      return _journalDocs;
    });
  }

  Future<Note> getSingleNote(String documentID) {
    return _firestore
        .collection(_collectionNotes)
        .document(documentID)
        .get()
        .then((documentSnapshot) {
      return Note.fromDoc(documentSnapshot);
    });
  }

  Future<bool> addSingleNote(Note note) async {
    DocumentReference _documentReference =
        await _firestore.collection(_collectionNotes).add({
      'date': note.date,
      'title': note.title,
      'description': note.description,
      'uid': note.uid,
    });
    return _documentReference.documentID != null;
  }

  void updateNote(Note note) async {
    await _firestore
        .collection(_collectionNotes)
        .document(note.documentID)
        .updateData({
      'date': note.date,
      'title': note.title,
      'description': note.description,
    }).catchError((error) => print('Error updating: $error'));
  }

  void updateNoteWithTransaction(Note note) async {
    DocumentReference _documentReference =
        _firestore.collection(_collectionNotes).document(note.documentID);
    var noteData = {
      'date': note.date,
      'title': note.title,
      'description': note.description,
    };
    _firestore.runTransaction((transaction) async {
      await transaction
          .update(_documentReference, noteData)
          .catchError((error) => print('Error updating: $error'));
    });
  }

  void deleteNote(Note note) async {
    await _firestore
        .collection(_collectionNotes)
        .document(note.documentID)
        .delete()
        .catchError((error) => print('Error deleting: $error'));
  }
}
