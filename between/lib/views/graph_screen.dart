import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // La librería estrella
import '../view_models/mood_view_model.dart';

class GraphScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtenemos el ViewModel
    final moodViewModel = Provider.of<MoodViewModel>(context);
    // Ejecutamos nuestro algoritmo matemático
    final dailyAverages = moodViewModel.getAverageMoodsPerDay();

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard de Progreso'),
        backgroundColor: Colors.indigo, // Un color que transmite calma
        foregroundColor: Colors.white,
      ),
      body: dailyAverages.isEmpty
          ? Center(
              child: Text(
                "Registra tu ánimo un par de días\npara ver tu progreso aquí.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Tu flujo emocional",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  
                  // --- EL WIDGET DE LA GRÁFICA ---
                  Expanded(
                    child: LineChart(
                      _buildLineChartData(dailyAverages),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // --- CONFIGURACIÓN DEL MOTOR GRÁFICO ---
  LineChartData _buildLineChartData(Map<String, double> data) {
    // 1. Convertir nuestro Map en Puntos (X, Y) para la gráfica
    List<FlSpot> spots = [];
    int index = 0;
    data.forEach((date, average) {
      spots.add(FlSpot(index.toDouble(), average));
      index++; // El eje X es el índice del día, el eje Y es el promedio del ánimo
    });

    return LineChartData(
      // Quitamos la cuadrícula de fondo para un diseño más moderno y limpio
      gridData: FlGridData(show: false), 
      borderData: FlBorderData(show: false),
      // Definimos los límites (Y va del 1 al 5 por nuestros emojis)
      minX: 0,
      maxX: (data.length - 1).toDouble() > 0 ? (data.length - 1).toDouble() : 1,
      minY: 1,
      maxY: 5,
      
      // 2. Configurar los Textos de los Ejes (X y Y)
      titlesData: FlTitlesData(
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        
        // Eje Y (Izquierda): Mostramos Emojis clave como referencia
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 2, // Mostrar titulo cada 2 niveles
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              switch (value.toInt()) {
                case 1: return Text('😡', style: TextStyle(fontSize: 16));
                case 3: return Text('😐', style: TextStyle(fontSize: 16));
                case 5: return Text('😄', style: TextStyle(fontSize: 16));
                default: return Text('');
              }
            },
          ),
        ),
        
        // Eje X (Abajo): Mostramos las fechas
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < data.keys.length) {
                // Extraemos "MES-DIA" (ej. "04-06") para que quepa bien
                String dateStr = data.keys.elementAt(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(dateStr.substring(5, 10), style: TextStyle(fontSize: 12, color: Colors.grey)),
                );
              }
              return Text('');
            },
          ),
        ),
      ),
      
      // 3. Estilo de la Línea
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true, // Línea suavizada (muy importante para apps de salud)
          color: Colors.indigoAccent,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true), // Mostrar el punto exacto de cada día
          belowBarData: BarAreaData(
            show: true,
            color: Colors.indigoAccent.withOpacity(0.2), // Relleno translúcido bajo la curva
          ),
        ),
      ],
    );
  }
}