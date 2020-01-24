class Note {
  String documentID; //note id created by firestore
  String date;
  String title;
  String description;
  String uid; //user id gotten from auth user

  Note({this.documentID, this.date, this.title, this.description, this.uid});

  factory Note.fromDoc(dynamic doc) => Note(
      documentID: doc.documentID,
      date: doc["date"],
      title: doc["title"],
      description: doc["description"],
      uid: doc["uid"]);
}
