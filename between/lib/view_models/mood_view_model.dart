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

  // --- ALGORITMO DEL SPRINT 3: Procesamiento de datos para gráficas ---
  
  Map<String, double> getAverageMoodsPerDay() {
    Map<String, List<int>> groupedMoods = {};

    for (var mood in _moods) {
      // Extraer solo la parte de la fecha (YYYY-MM-DD) para agrupar por día
      String dateKey = mood.date.toIso8601String().substring(0, 10);
      
      if (!groupedMoods.containsKey(dateKey)) {
        groupedMoods[dateKey] = []; // Inicializamos la lista si el día no existe
      }
      groupedMoods[dateKey]!.add(mood.moodValue);
    }

    // Calcular el promedio por cada día
    
    Map<String, double> dailyAverages = {};
    
    groupedMoods.forEach((dateKey, values) {
      // Sumamos todos los valores del día
      double sum = values.fold(0, (previous, current) => previous + current);
      // Dividimos entre la cantidad de registros para sacar el promedio
      dailyAverages[dateKey] = sum / values.length;
    });

    // Ordenar cronológicamente los datos para que la gráfica los muestre en el orden correcto
    var sortedKeys = dailyAverages.keys.toList()..sort();
    Map<String, double> sortedAverages = {};
    
    for (var key in sortedKeys) {
      sortedAverages[key] = dailyAverages[key]!;
    }

    return sortedAverages;
  }
}