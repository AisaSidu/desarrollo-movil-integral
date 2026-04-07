import 'package:between/views/session_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/mood_view_model.dart';
import 'diary_screen.dart'; // Importamos la pantalla del diario
import 'graph_screen.dart';

class MoodScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Accedemos al ViewModel
    final moodViewModel = Provider.of<MoodViewModel>(context);

    return Scaffold(
      // 1. APPBAR ACTUALIZADO: Aquí agregamos el botón para ir al Diario
      appBar: AppBar(
        title: Text('Registro de Ánimo'),
        actions: [
          IconButton(
            icon: Icon(Icons.insights), // Ícono de gráfica
            tooltip: 'Ver mi Progreso',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GraphScreen()),
              );
            },
          ),
          // 2. NUEVO: Ir al Resumen de Sesión
          IconButton(
            icon: Icon(Icons.assignment_ind), // Ícono de un reporte personal
            tooltip: 'Resumen para Terapia',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SessionSummaryScreen())),
          ),
          IconButton(
            icon: Icon(Icons.menu_book), // Ícono de librito
            tooltip: 'Ir a mi Diario',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DiaryScreen()),
              );
            },
          ),
        ],
      ),
      
      // 2. CUERPO DE LA PANTALLA: Igual que antes
      body: Column(
        children: [
          SizedBox(height: 20),
          Text("¿Cómo te sientes hoy?", style: TextStyle(fontSize: 20)),
          SizedBox(height: 20),
          
          // --- ÁREA DE INPUT (Botones) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MoodButton(emoji: "😡", value: 1, vm: moodViewModel),
              _MoodButton(emoji: "😢", value: 2, vm: moodViewModel),
              _MoodButton(emoji: "😐", value: 3, vm: moodViewModel),
              _MoodButton(emoji: "🙂", value: 4, vm: moodViewModel),
              _MoodButton(emoji: "😄", value: 5, vm: moodViewModel),
            ],
          ),
          
          Divider(height: 40),
          
          // --- ÁREA DE LISTA (Historial para verificar que guardó) ---
          Expanded(
            child: ListView.builder(
              itemCount: moodViewModel.moods.length,
              itemBuilder: (context, index) {
                final mood = moodViewModel.moods[index];
                return ListTile(
                  leading: Text(mood.emoji, style: TextStyle(fontSize: 30)),
                  title: Text("Nivel: ${mood.moodValue}"),
                  subtitle: Text(mood.date.toString().substring(0, 16)),
                );
              },
            ),
          ),
        ],
      ),
      // NOTA: Eliminamos el floatingActionButton de aquí, porque ya está en DiaryScreen
    );
  }
}

// Widget auxiliar para los botones de emojis (se queda igual)
class _MoodButton extends StatelessWidget {
  final String emoji;
  final int value;
  final MoodViewModel vm;

  const _MoodButton({required this.emoji, required this.value, required this.vm});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => vm.addMood(emoji, value),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(emoji, style: TextStyle(fontSize: 35)),
      ),
    );
  }
}