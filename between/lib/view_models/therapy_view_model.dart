import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../data/database_helper.dart';
import '../services/notification_service.dart';

class TherapyViewModel extends ChangeNotifier {
  DateTime? _nextSessionDate;
  String _frequency = 'ninguna'; // Opciones: 'ninguna', 'semanal', 'quincenal', 'mensual'

  final DatabaseHelper _dbHelper = DatabaseHelper();

  DateTime? get nextSessionDate => _nextSessionDate;
  String get frequency => _frequency;
  bool get hasActiveTherapy => _frequency != 'ninguna' && _nextSessionDate != null;

  // Constructor: Carga los ajustes guardados al abrir la app
  TherapyViewModel() {
    loadSettings();
  }

  // --- 1. CARGAR DATOS DE SQLITE ---
  Future<void> loadSettings() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('settings');

    for (var map in maps) {
      if (map['key'] == 'frequency') {
        _frequency = map['value'];
      } else if (map['key'] == 'nextSessionDate') {
        _nextSessionDate = DateTime.tryParse(map['value']);
      }
    }
    notifyListeners();
  }

  // --- 2. GUARDAR DATOS EN SQLITE Y PROGRAMAR ALERTA ---
  Future<void> setTherapySchedule(DateTime sessionDate, String frequency) async {
    _nextSessionDate = sessionDate;
    _frequency = frequency;

    final db = await _dbHelper.database;
    
    // Usamos 'replace' para que si ya existe la llave, simplemente la actualice
    await db.insert('settings', {'key': 'frequency', 'value': frequency}, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('settings', {'key': 'nextSessionDate', 'value': sessionDate.toIso8601String()}, conflictAlgorithm: ConflictAlgorithm.replace);

    if (hasActiveTherapy) {
      _scheduleNotification();
    } else {
      _cancelNotification();
    }

    notifyListeners();
  }

  // --- 3. CONEXIÓN CON EL SERVICIO DE NOTIFICACIONES ---
  void _scheduleNotification() {
    if (_nextSessionDate == null) return;

    DateTime reminderDate = _nextSessionDate!.subtract(Duration(days: 1));

    if (reminderDate.isBefore(DateTime.now())) {
      print("La sesión es en menos de 24 horas, no se programará el aviso previo.");
      return;
    }

    // Le pasamos la fecha calculada a nuestro servicio nativo
    NotificationService().scheduleReminderForDate(reminderDate);
  }

  void _cancelNotification() {
    NotificationService().cancelScheduledReminders();
  }

  // --- 4. CÁLCULO DE LA SIGUIENTE SESIÓN ---
  Future<void> calculateNextRolloverDate() async {
    if (!hasActiveTherapy || _nextSessionDate == null) return;

    switch (_frequency) {
      case 'semanal':
        _nextSessionDate = _nextSessionDate!.add(Duration(days: 7));
        break;
      case 'quincenal':
        _nextSessionDate = _nextSessionDate!.add(Duration(days: 14));
        break;
      case 'mensual':
        _nextSessionDate = DateTime(_nextSessionDate!.year, _nextSessionDate!.month + 1, _nextSessionDate!.day, _nextSessionDate!.hour, _nextSessionDate!.minute);
        break;
    }
    
    // Guardamos la nueva fecha calculada y reprogramamos
    await setTherapySchedule(_nextSessionDate!, _frequency);
  }
}