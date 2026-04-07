import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/notes_view_model.dart';
import '../view_models/mood_view_model.dart';
import '../services/notification_service.dart';

class SessionSummaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtenemos nuestros datos de ambos ViewModels
    final notesVM = Provider.of<NotesViewModel>(context);
    final moodVM = Provider.of<MoodViewModel>(context);

    // --- LÓGICA DE FILTRADO (Últimos 7 días) ---
    final DateTime sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));

    // 1. Filtramos las notas recientes
    final recentNotes = notesVM.notes.where((note) => note.date.isAfter(sevenDaysAgo)).toList();

    // 2. Calculamos el promedio de ánimo de esta semana
    final allAverages = moodVM.getAverageMoodsPerDay();
    double weeklySum = 0;
    int daysCount = 0;

    allAverages.forEach((dateStr, average) {
      DateTime date = DateTime.parse(dateStr);
      if (date.isAfter(sevenDaysAgo)) {
        weeklySum += average;
        daysCount++;
      }
    });

    final double weeklyAverage = daysCount > 0 ? (weeklySum / daysCount) : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen para Terapia'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- TARJETA DE ÁNIMO GENERAL ---
            Card(
              color: Colors.deepPurple.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      "Tu ánimo esta semana",
                      style: TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      daysCount > 0 ? weeklyAverage.toStringAsFixed(1) : "-",
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                    Text(
                      "Escala del 1 al 5",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 30),
            
            // --- LISTA DE TEMAS A TRATAR ---
            Text(
              "Temas de tus últimos 7 días:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            
            recentNotes.isEmpty
                ? Text("No escribiste notas esta semana. ¡Aún estás a tiempo de anotar algo para tu sesión!", style: TextStyle(color: Colors.grey))
                : ListView.builder(
                    shrinkWrap: true, // Importante cuando ListView está dentro de un SingleChildScrollView
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: recentNotes.length,
                    itemBuilder: (context, index) {
                      final note = recentNotes[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.check_circle_outline, color: Colors.deepPurple),
                        title: Text(note.title, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 30),
            ElevatedButton.icon(
              icon: Icon(Icons.notifications_active),
              label: Text("Probar Alerta de Terapia"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () async {
                // Lanzamos la notificación
                await NotificationService().showTherapyReminder();
              },
            ),
          ],
        ),
      ),
    );
  }
}