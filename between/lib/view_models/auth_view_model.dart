import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; // Importa sqflite para las excepciones
import '../data/database_helper.dart';
import '../data/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoggedIn = false;
  
  bool get isLoggedIn => _isLoggedIn;

  // --- REGISTRO (SIGNUP) ---
  Future<bool> signup(String email, String password) async {
    final db = await _dbHelper.database;
    
    // Aquí podrías agregar cifrado real con el paquete 'encrypt'
    // Por ahora, para la evidencia rápida, guardamos directo (o un hash simple)
    final newUser = User(email: email, password: password);

    try {
      await db.insert('users', newUser.toMap());
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      // Si el email ya existe (error de restricción UNIQUE)
      return false;
    }
  }

  // --- INICIO DE SESIÓN (LOGIN) ---
  Future<bool> login(String email, String password) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}