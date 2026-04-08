import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/database_helper.dart';

class CloudSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Función para subir las notas locales a la nube
  Future<bool> syncLocalDataToCloud() async {
    try {
      final db = await _dbHelper.database;
      
      // 1. Leemos las notas de tu SQLite local
      final List<Map<String, dynamic>> localNotes = await db.query('notes');

      // 2. Definimos dónde se guardarán (Usamos un ID genérico "user_demo" por ahora)
      // En producción, este ID vendría de Firebase Auth.
      final userNotesCollection = _firestore.collection('users').doc('user_demo').collection('notes');

      // 3. Subimos cada nota a la nube
      for (var note in localNotes) {
        String noteId = note['id'].toString(); 
        
        await userNotesCollection.doc(noteId).set({
          'title': note['title'], 
          'content': note['content'], // En tu app real, esto ya va cifrado
          'date': note['date'],
          'synced_at': DateTime.now().toIso8601String(), // Marca de tiempo de la sincronización
        });
      }
      
      print("✅ Sincronización exitosa");
      return true;
    } catch (e) {
      print("❌ Error al sincronizar: $e");
      return false;
    }
  }
}