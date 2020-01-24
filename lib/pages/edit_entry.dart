import 'package:flutter/material.dart';
import 'package:note_app/blocs/note_edit_bloc.dart';
import 'package:note_app/blocs/note_edit_bloc_provider.dart';
import 'package:note_app/classes/FormatDates.dart';

class EditEntry extends StatefulWidget {
  @override
  _EditEntryState createState() => _EditEntryState();
}

class _EditEntryState extends State<EditEntry> {
  NoteEditBloc _noteEditBloc;
  FormatDates _formatDates;
  TextEditingController _noteController;
  TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _formatDates = FormatDates();
    _noteController = TextEditingController();
    _titleController = TextEditingController();
    _titleController.text = '';
    _noteController.text = '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _noteEditBloc = NoteEditBlocProvider.of(context).noteEditBloc;
  }

  @override
  dispose() {
    _noteController.dispose();
    _titleController.dispose();
    _noteEditBloc.dispose();
    super.dispose();
  }

  // Date Picker
  Future<String> _selectDate(String selectedDate) async {
    DateTime _initialDate = DateTime.parse(selectedDate);

    final DateTime _pickedDate = await showDatePicker(
      context: context,
      initialDate: _initialDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (_pickedDate != null) {
      selectedDate = DateTime(
              _pickedDate.year,
              _pickedDate.month,
              _pickedDate.day,
              _initialDate.hour,
              _initialDate.minute,
              _initialDate.second,
              _initialDate.millisecond,
              _initialDate.microsecond)
          .toString();
    }
    return selectedDate;
  }

  void _addOrUpdateNote() {
    _noteEditBloc.saveNoteChanged.add('Save');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Note',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        elevation: 0.0,
      ),
      body: SafeArea(
        minimum: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              StreamBuilder(
                stream: _noteEditBloc.dateEdit,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  return FlatButton(
                    padding: EdgeInsets.all(0.0),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.calendar_today,
                          size: 22.0,
                          color: Colors.black54,
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        Text(
                          _formatDates
                              .dateFormatShortMonthDayYear(snapshot.data),
                          style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                    onPressed: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      String _pickerDate = await _selectDate(snapshot.data);
                      _noteEditBloc.dateEditChanged.add(_pickerDate);
                    },
                  );
                },
              ),
              StreamBuilder(
                  stream: _noteEditBloc.moodEdit,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    // Use the copyWith to make sure when you edit TextField the cursor does not bounce to the first character
                    _titleController.value =
                        _titleController.value.copyWith(text: snapshot.data);
                    return TextField(
                      controller: _titleController,
                      textInputAction: TextInputAction.newline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        icon: Icon(Icons.subject),
                      ),
                      maxLines: null,
                      onChanged: (note) =>
                          _noteEditBloc.moodEditChanged.add(note),
                    );
                  }),
              StreamBuilder(
                stream: _noteEditBloc.noteEdit,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  // Use the copyWith to make sure when you edit TextField the cursor does not bounce to the first character
                  _noteController.value =
                      _noteController.value.copyWith(text: snapshot.data);
                  return TextField(
                    controller: _noteController,
                    textInputAction: TextInputAction.newline,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      icon: Icon(
                        Icons.subject,
                        color: Colors.white,
                      ),
                    ),
                    maxLines: null,
                    onChanged: (note) =>
                        _noteEditBloc.noteEditChanged.add(note),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    color: Colors.grey.shade100,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: 8.0),
                  FlatButton(
                    child: Text('Save'),
                    color: Colors.lightBlue,
                    onPressed: () {
                      _addOrUpdateNote();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
