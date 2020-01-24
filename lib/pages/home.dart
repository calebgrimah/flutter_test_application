import 'package:flutter/material.dart';
import 'package:note_app/blocs/authentication_bloc.dart';
import 'package:note_app/blocs/authentication_bloc_provider.dart';
import 'package:note_app/blocs/home_bloc.dart';
import 'package:note_app/blocs/home_bloc_provider.dart';
import 'package:note_app/blocs/note_edit_bloc.dart';
import 'package:note_app/blocs/note_edit_bloc_provider.dart';
import 'package:note_app/classes/FormatDates.dart';
import 'package:note_app/models/Note.dart';
import 'package:note_app/services/db_firestore.dart';

import 'edit_entry.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AuthenticationBloc _authenticationBloc;
  HomeBloc _homeBloc;
  String _uid;
  FormatDates _formatDates = FormatDates();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authenticationBloc =
        AuthenticationBlocProvider.of(context).authenticationBloc;
    _homeBloc = HomeBlocProvider.of(context).homeBloc;
    _uid = HomeBlocProvider.of(context).uid;
  }

  @override
  void dispose() {
    _homeBloc.dispose();
    super.dispose();
  }

  // Add or Edit Note Entry and call the Show Entry Dialog
  void _addOrEditNote({bool add, Note note}) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => NoteEditBlocProvider(
                noteEditBloc: NoteEditBloc(add, note, DbFirestoreService()),
                child: EditEntry(),
              ),
          fullscreenDialog: true),
    );
  }

  // Confirm Deleting a Journal Entry
  Future<bool> _confirmDeleteNote() async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Note"),
          content: Text("Are you sure you would like to Delete Note?"),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            FlatButton(
              child: Text(
                'DELETE',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () {
              _authenticationBloc.logoutUser.add(true);
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _homeBloc.listNote,
        builder: ((BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            return _buildListViewSeparated(snapshot);
          } else {
            print('Center Has been summoned');
            return Center(
              child: Container(
                child: Text('Add Notes.'),
              ),
            );
          }
        }),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Note Entry',
        backgroundColor: Colors.lightBlue,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () async {
          _addOrEditNote(add: true, note: Note(uid: _uid));
        },
      ),
    );
  }

  // Build the ListView with Separator
  Widget _buildListViewSeparated(AsyncSnapshot snapshot) {
    return ListView.separated(
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        String _titleDate =
            _formatDates.dateFormatShortMonthDayYear(snapshot.data[index].date);
        String _subtitle = snapshot.data[index].title +
            "\n" +
            snapshot.data[index].description;
        return Dismissible(
          key: Key(snapshot.data[index].documentID),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: ListTile(
            leading: Column(
              children: <Widget>[
                Text(
                  _formatDates.dateFormatDayNumber(snapshot.data[index].date),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 29.0,
                      color: Colors.lightBlue),
                ),
                Text(_formatDates
                    .dateFormatShortDayName(snapshot.data[index].date)),
              ],
            ),
            title: Text(
              _titleDate,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_subtitle),
            onTap: () {
              _addOrEditNote(
                add: false,
                note: Note(
                    documentID: snapshot.data[index].documentID,
                    date: snapshot.data[index].date,
                    title: snapshot.data[index].title,
                    description: snapshot.data[index].description,
                    uid: snapshot.data[index].uid),
              );
            },
          ),
          // ignore: missing_return
          confirmDismiss: (direction) async {
            bool confirmDelete = await _confirmDeleteNote();
            if (confirmDelete) {
              _homeBloc.deleteNote.add(snapshot.data[index]);
            }
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          color: Colors.grey,
        );
      },
    );
  }
}
