import 'package:flutter/material.dart';
import 'package:note_app/models/Note.dart';

import 'note_edit_bloc.dart';

class NoteEditBlocProvider extends InheritedWidget {
  final NoteEditBloc noteEditBloc;
  final bool add;
  final Note note;

  const NoteEditBlocProvider(
      {Key key, Widget child, this.noteEditBloc, this.add, this.note})
      : super(key: key, child: child);

  static NoteEditBlocProvider of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<NoteEditBlocProvider>());
  }

  @override
  bool updateShouldNotify(NoteEditBlocProvider old) =>
      noteEditBloc != old.noteEditBloc;
}
