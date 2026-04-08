import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart'; 
// ¡Importaciones vitales para la biometría que faltaban!
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

import '../data/database_helper.dart';
import '../data/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  // Instancia de biometría que faltaba
  final LocalAuthentication _auth = LocalAuthentication(); 
  
  // Unificamos el nombre a _isAuthenticated en todo el archivo
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  // --- 1. GUARDAR SESIÓN EN CACHÉ ---
  Future<void> saveLoginSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    _isAuthenticated = true;
    notifyListeners();
  }

  // --- 2. VERIFICAR SESIÓN Y PEDIR HUELLA/PIN AL ABRIR LA APP ---
  // --- 2. VERIFICAR SESIÓN Y PEDIR HUELLA/PIN AL ABRIR LA APP ---
  // --- 2. VERIFICAR SESIÓN Y PEDIR HUELLA/PIN AL ABRIR LA APP ---
  Future<bool> checkAndAuthenticate() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasPreviousSession = prefs.getBool('isLoggedIn') ?? false;

    if (!hasPreviousSession) {
      return false; // Nunca ha iniciado sesión
    }

    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Desbloquea Between para acceder a tu diario',
        // Dejamos únicamente los parámetros que tu versión de local_auth reconoce
        biometricOnly: false, // ¡Vital! Permite usar el PIN si la huella falla o no existe
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Autenticación requerida',
            cancelButton: 'Cancelar',
          ),
        ],
      );

      if (didAuthenticate) {
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error biométrico: $e");
      return false; 
    }
  }
  

  // --- 3. REGISTRO (SIGNUP) ---
  Future<bool> signup(String email, String password) async {
    final db = await _dbHelper.database;
    final newUser = User(email: email, password: password);

    try {
      await db.insert('users', newUser.toMap());
      // ¡Guardamos la sesión automáticamente tras registrarse!
      await saveLoginSession();
      return true;
    } catch (e) {
      return false;
    }
  }

  // --- 4. INICIO DE SESIÓN (LOGIN) ---
  Future<bool> login(String email, String password) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      // ¡Guardamos la sesión automáticamente tras hacer login!
      await saveLoginSession();
      return true;
    } else {
      return false;
    }
  }

  // --- 5. CERRAR SESIÓN ---
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    _isAuthenticated = false;
    notifyListeners();
  }
}