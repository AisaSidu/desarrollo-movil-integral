import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/notes_view_model.dart';
import 'add_note_screen.dart';
import 'mood_screen.dart'; // Para importar BetweenColors y BetweenBottomNav

class DiaryScreen extends StatelessWidget {
  // Función auxiliar para formatear la fecha bonito (ej. "7 abr · 14:30")
  String _formatDate(DateTime date) {
    const months = ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"];
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return "${date.day} ${months[date.month - 1]} · $h:$min";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BetweenColors.lilacFog,
      body: Stack(
        children: [
          // ── Blob decorativo ──────────────────────────────────────
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [BetweenColors.lightTeal.withOpacity(0.28), BetweenColors.lightTeal.withOpacity(0.00)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                  child: Text(
                    "Mi Diario",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: BetweenColors.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),

                // ── Lista de Notas ──────────────────────────────────────
                Expanded(
                  child: Consumer<NotesViewModel>(
                    builder: (context, notesVM, child) {
                      if (notesVM.notes.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: notesVM.notes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final note = notesVM.notes[index];

                          return Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: BetweenColors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: BetweenColors.deepPurple.withOpacity(0.06),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: BetweenColors.mintFog,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.menu_book_rounded, color: BetweenColors.teal, size: 18),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        note.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: BetweenColors.textDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  note.content,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14, color: BetweenColors.textMuted, height: 1.4),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 14, color: BetweenColors.lavender),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatDate(note.date),
                                      style: const TextStyle(fontSize: 12, color: BetweenColors.lavender, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // ── Botón Flotante Estilizado ──────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddNoteScreen())),
        backgroundColor: BetweenColors.deepPurple,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.edit_rounded, color: BetweenColors.white),
      ),
      
      // ── Barra de Navegación ───────────────────────────────────────────
      bottomNavigationBar: BetweenBottomNav(context: context, activeTab: "Diario"),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: BetweenColors.lavender.withOpacity(0.3), shape: BoxShape.circle),
            child: const Icon(Icons.edit_document, color: BetweenColors.softPurple, size: 36),
          ),
          const SizedBox(height: 20),
          const Text("Tu diario está en blanco", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: BetweenColors.textDark)),
          const SizedBox(height: 8),
          const Text("Escribe sobre tu día o tus reflexiones.\nTodo se guarda de forma segura.", textAlign: TextAlign.center, style: TextStyle(color: BetweenColors.textMuted, height: 1.5)),
        ],
      ),
    );
  }
}