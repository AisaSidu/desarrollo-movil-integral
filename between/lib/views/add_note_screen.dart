import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/notes_view_model.dart';
import 'mood_screen.dart'; // Para BetweenColors

class AddNoteScreen extends StatefulWidget {
  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>(); 
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BetweenColors.lilacFog,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: BetweenColors.deepPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Nueva Nota",
          style: TextStyle(color: BetweenColors.textDark, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Instrucción ─────────────────────────────────────────
                const Text(
                  "Plasma tus pensamientos",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: BetweenColors.textDark, letterSpacing: -0.5),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Este es tu espacio seguro y cifrado. Nadie más puede leer lo que escribes aquí.",
                  style: TextStyle(color: BetweenColors.textMuted, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 30),

                // ── Campo de Título ─────────────────────────────────────
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: BetweenColors.textDark),
                  decoration: InputDecoration(
                    hintText: "Título (Ej. Reflexión de hoy)",
                    hintStyle: TextStyle(color: BetweenColors.textMuted.withOpacity(0.6)),
                    filled: true,
                    fillColor: BetweenColors.white,
                    prefixIcon: const Icon(Icons.title_rounded, color: BetweenColors.softPurple),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? "Por favor ingresa un título" : null,
                ),
                const SizedBox(height: 20),

                // ── Campo de Contenido ──────────────────────────────────
                TextFormField(
                  controller: _contentController,
                  style: const TextStyle(color: BetweenColors.textDark, height: 1.5),
                  decoration: InputDecoration(
                    hintText: "¿Qué está pasando por tu mente?",
                    hintStyle: TextStyle(color: BetweenColors.textMuted.withOpacity(0.6)),
                    filled: true,
                    fillColor: BetweenColors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(20),
                  ),
                  maxLines: 12, // Más alto para dar sensación de hoja de papel
                  validator: (value) => (value == null || value.isEmpty) ? "El contenido no puede estar vacío" : null,
                ),
                const SizedBox(height: 40),

                // ── Botón Guardar ───────────────────────────────────────
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BetweenColors.deepPurple,
                    foregroundColor: BetweenColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 8,
                    shadowColor: BetweenColors.deepPurple.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Provider.of<NotesViewModel>(context, listen: false).addNote(
                        _titleController.text, 
                        _contentController.text
                      );
                      
                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Nota guardada en tu diario"), 
                          backgroundColor: BetweenColors.teal,
                          behavior: SnackBarBehavior.floating, // Flotante para que se vea moderno
                        )
                      );
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_rounded, size: 20),
                      SizedBox(width: 8),
                      Text("Guardar Entrada", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}