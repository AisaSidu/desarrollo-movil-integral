import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/models/mood_model.dart';

class MoodViewModel extends ChangeNotifier {
  // Lista privada de estados de ánimo
  List<Mood> _moods = [];
  
  // Getter público para que la vista pueda leer la lista
  List<Mood> get moods => _moods;

  // Referencia a la base de datos
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Constructor: Carga los datos existentes al iniciar
  MoodViewModel() {
    loadMoods();
  }

  // 1. Cargar datos de SQLite
  Future<void> loadMoods() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('moods', orderBy: "date DESC");
    
    _moods = List.generate(maps.length, (i) {
      return Mood.fromMap(maps[i]);
    });
    
    // ¡Avisar a la vista que hay nuevos datos!
    notifyListeners();
  }

  // 2. Agregar un nuevo estado de ánimo (Lógica de negocio)
  Future<void> addMood(String emoji, int value) async {
    final newMood = Mood(
      date: DateTime.now(),
      moodValue: value,
      emoji: emoji,
    );

    final db = await _dbHelper.database;
    await db.insert('moods', newMood.toMap());

    // Recargar la lista para mostrar el cambio
    await loadMoods();
  }
}