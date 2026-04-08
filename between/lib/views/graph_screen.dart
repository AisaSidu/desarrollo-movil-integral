import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../view_models/mood_view_model.dart';
import 'mood_screen.dart'; // Para importar BetweenColors y _BetweenBottomNav (o tu archivo de tema)

class GraphScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final moodViewModel = Provider.of<MoodViewModel>(context);
    final dailyAverages = moodViewModel.getAverageMoodsPerDay();

    return Scaffold(
      backgroundColor: BetweenColors.lilacFog,
      body: Stack(
        children: [
          // ── Blob decorativo superior ──────────────────────────────────────
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    BetweenColors.lightTeal.withOpacity(0.28),
                    BetweenColors.lightTeal.withOpacity(0.00),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header Simple ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Text(
                    "Tu flujo emocional",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: BetweenColors.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),

                // ── Contenido de la Gráfica ──────────────────────────────────────
                Expanded(
                  child: dailyAverages.isEmpty
                      ? _buildEmptyGraphState()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(16, 30, 24, 20),
                            decoration: BoxDecoration(
                              color: BetweenColors.white,
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: BetweenColors.deepPurple.withOpacity(0.08),
                                  blurRadius: 30,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: LineChart(_buildLineChartData(dailyAverages)),
                          ),
                        ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BetweenBottomNav(context: context, activeTab: "Progreso"),
    );
  }

  // --- DISEÑO DE LA GRÁFICA ---
  LineChartData _buildLineChartData(Map<String, double> data) {
    List<FlSpot> spots = [];
    int index = 0;
    data.forEach((date, average) {
      spots.add(FlSpot(index.toDouble(), average));
      index++;
    });

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) => FlLine(
          color: BetweenColors.lavender.withOpacity(0.3),
          strokeWidth: 1,
          dashArray: [5, 5], // Líneas punteadas elegantes
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (data.length - 1).toDouble() > 0 ? (data.length - 1).toDouble() : 1,
      minY: 1,
      maxY: 5,
      titlesData: FlTitlesData(
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 34,
            getTitlesWidget: (value, meta) {
              String emoji = '';
              switch (value.toInt()) {
                case 1: emoji = '😡'; break;
                case 3: emoji = '😐'; break;
                case 5: emoji = '😄'; break;
              }
              return Text(emoji, style: const TextStyle(fontSize: 16));
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < data.keys.length) {
                String dateStr = data.keys.elementAt(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    dateStr.substring(5, 10), 
                    style: const TextStyle(fontSize: 11, color: BetweenColors.textMuted, fontWeight: FontWeight.w600)
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: BetweenColors.deepPurple,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
              radius: 4,
              color: BetweenColors.white,
              strokeWidth: 2,
              strokeColor: BetweenColors.deepPurple,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                BetweenColors.deepPurple.withOpacity(0.3),
                BetweenColors.teal.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyGraphState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_graph_rounded, size: 60, color: BetweenColors.lavender),
          const SizedBox(height: 16),
          const Text(
            "Sin datos suficientes",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: BetweenColors.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            "Registra tu ánimo un par de días\npara ver tu progreso aquí.",
            textAlign: TextAlign.center,
            style: TextStyle(color: BetweenColors.textMuted),
          ),
        ],
      ),
    );
  }
}