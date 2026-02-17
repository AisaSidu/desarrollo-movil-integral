class Mood {
  final int? id;
  final DateTime date;
  final int moodValue; // Del 1 (muy mal) al 5 (excelente) para la gráfica
  final String emoji;  // El emoji visual (ej: "😊")

  Mood({
    this.id,
    required this.date,
    required this.moodValue,
    required this.emoji,
  });

  // Convertir nuestro objeto a un Map (para guardarlo en SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(), // SQLite guarda fechas como texto
      'mood_value': moodValue,
      'emoji': emoji,
    };
  }

  // Convertir lo que viene de SQLite (Map) a nuestro objeto Mood
  factory Mood.fromMap(Map<String, dynamic> map) {
    return Mood(
      id: map['id'],
      date: DateTime.parse(map['date']),
      moodValue: map['mood_value'],
      emoji: map['emoji'],
    );
  }
}