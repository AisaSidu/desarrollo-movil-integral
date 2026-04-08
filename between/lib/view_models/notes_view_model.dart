import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/models/note_model.dart';
import '../data/encryption_helper.dart';

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
    
    _notes = List.generate(maps.length, (i) {
      final map = maps[i];
      return Note(
        id: map['id'],
        date: DateTime.parse(map['date']),
        title: map['title'],
        // ¡Aquí DESCIFRAMOS el contenido que viene de la base de datos!
        content: EncryptionHelper.decryptText(map['content']),
      );
    });
    notifyListeners();
  }

  // Crear nueva nota
  Future<void> addNote(String title, String content) async {
    final newNote = Note(
      date: DateTime.now(),
      title: title,
      // ¡Aquí CIFRAMOS el contenido antes de armar el objeto!
      content: EncryptionHelper.encryptText(content),
    );

    final db = await _dbHelper.database;
    await db.insert('notes', newNote.toMap());
    await loadNotes();
  }
}