import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:note_app/models/Note.dart';
import 'package:note_app/services/db_firestore.dart';

class MockDBFirestore extends Mock implements DbFirestoreService {}

class FirebaseUserMock extends Mock implements FirebaseUser {
  @override
  String get displayName => 'John Doe';

  @override
  String get uid => 'uid';

  @override
  String get email => 'johndoe@mail.com';

  @override
  String get photoUrl => 'http://www.adityag.me';
}

void main() {
  MockDBFirestore dbFirestore = MockDBFirestore();
  group('serviceTests', () {
    test('returns a list of notes if the call is successful', () async {
      final noteService = MockDBFirestore();
      final firebaseUser = FirebaseUserMock();
      Stream<List<Note>> valu = Stream.fromIterable([]);
      when(noteService.getNoteList(firebaseUser.uid)).thenAnswer((_) => valu);
      expect(await noteService.getNoteList(firebaseUser.uid),
          isInstanceOf<Stream<List<Note>>>());
    });
  });
}
