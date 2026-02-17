import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/mood_view_model.dart';

class MoodScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Accedemos al ViewModel
    final moodViewModel = Provider.of<MoodViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Registro de Ánimo')),
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
    );
  }
}

// Widget auxiliar para los botones
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