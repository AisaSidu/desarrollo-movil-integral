import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/notes_view_model.dart';
import '../view_models/mood_view_model.dart';
import '../view_models/therapy_view_model.dart';
import 'therapy_config_screen.dart';
import 'mood_screen.dart'; // Para colores y bottom nav

class SessionSummaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notesVM = Provider.of<NotesViewModel>(context);
    final moodVM = Provider.of<MoodViewModel>(context);
    
    final DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentNotes = notesVM.notes.where((note) => note.date.isAfter(sevenDaysAgo)).toList();

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
                // ── Header con botón de configuración ───────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Resumen de Terapia",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: BetweenColors.textDark, letterSpacing: -0.3),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TherapyConfigScreen())),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: BetweenColors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: BetweenColors.deepPurple.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: const Icon(Icons.settings, color: BetweenColors.softPurple, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Tarjeta de Próxima Sesión (Mint Theme) ─────────
                        Consumer<TherapyViewModel>(
                          builder: (context, therapyVM, child) {
                            if (!therapyVM.hasActiveTherapy) {
                              return GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TherapyConfigScreen())),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: BetweenColors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: BetweenColors.lavender, width: 1.5, style: BorderStyle.solid),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_month_rounded, color: BetweenColors.softPurple),
                                      const SizedBox(width: 12),
                                      const Text("Configurar mi próxima sesión", style: TextStyle(color: BetweenColors.deepPurple, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final date = therapyVM.nextSessionDate!;
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: BetweenColors.mintFog,
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: [BoxShadow(color: BetweenColors.teal.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.event_available_rounded, color: BetweenColors.teal),
                                      const SizedBox(width: 8),
                                      Text("Siguiente Sesión", style: TextStyle(color: BetweenColors.teal, fontWeight: FontWeight.w700, fontSize: 14)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "${date.day}/${date.month}/${date.year} a las ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}",
                                    style: const TextStyle(fontSize: 22, color: BetweenColors.textDark, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                                  ),
                                  const SizedBox(height: 4),
                                  Text("Frecuencia: ${therapyVM.frequency.toUpperCase()}", style: const TextStyle(fontSize: 12, color: BetweenColors.textMuted)),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // ── Tarjeta de Promedio Semanal ────────────────────
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: BetweenColors.white,
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [BoxShadow(color: BetweenColors.deepPurple.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 8))],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Tu ánimo esta semana", style: TextStyle(fontSize: 14, color: BetweenColors.textMuted)),
                                  const SizedBox(height: 4),
                                  Text(
                                    daysCount > 0 ? weeklyAverage.toStringAsFixed(1) : "-",
                                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: BetweenColors.deepPurple),
                                  ),
                                  const Text("Escala del 1 al 5", style: TextStyle(fontSize: 11, color: BetweenColors.lavender)),
                                ],
                              ),
                              Container(
                                width: 60, height: 60,
                                decoration: BoxDecoration(color: BetweenColors.lilacFog, borderRadius: BorderRadius.circular(20)),
                                child: const Icon(Icons.bar_chart_rounded, color: BetweenColors.deepPurple, size: 30),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // ── Lista de Notas ─────────────────────────────────
                        const Text("Temas de tus últimos 7 días:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: BetweenColors.textDark)),
                        const SizedBox(height: 12),
                        
                        recentNotes.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Text("No escribiste notas esta semana. ¡Aún estás a tiempo de anotar algo para tu sesión!", style: TextStyle(color: BetweenColors.textMuted, height: 1.5), textAlign: TextAlign.center),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: recentNotes.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final note = recentNotes[index];
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: BetweenColors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [BoxShadow(color: BetweenColors.deepPurple.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.notes_rounded, color: BetweenColors.softPurple, size: 20),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(note.title, style: const TextStyle(fontWeight: FontWeight.w700, color: BetweenColors.textDark)),
                                              const SizedBox(height: 4),
                                              Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: BetweenColors.textMuted)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BetweenBottomNav(context: context, activeTab: "Sesión"),
    );
  }
}