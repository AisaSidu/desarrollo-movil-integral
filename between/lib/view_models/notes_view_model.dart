import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/models/note_model.dart';

class NotesViewModel extends ChangeNotifier {
  List<Note> _notes = [];
  List<Note> get notes => _notes;
  
  final DatabaseHelper _dbHelper = DatabaseHelper();

  NotesViewModel() {
    loadNotes();
  }

  // Leer notas de la base de datos
  Future<void> loadNotes() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('notes', orderBy: "date DESC");
    
    _notes = List.generate(maps.length, (i) => Note.fromMap(maps[i]));
    notifyListeners();
  }

  // Crear nueva nota (Lo que usará nuestro formulario)
  Future<void> addNote(String title, String content) async {
    final newNote = Note(
      date: DateTime.now(),
      title: title,
      content: content,
    );

    final db = await _dbHelper.database;
    await db.insert('notes', newNote.toMap());
    await loadNotes(); // Recargar la lista
  }
}