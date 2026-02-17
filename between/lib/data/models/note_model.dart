class Note {
  final int? id;
  final DateTime date;
  final String title;
  final String content;

  Note({
    this.id,
    required this.date,
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'content': content,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      date: DateTime.parse(map['date']),
      title: map['title'],
      content: map['content'],
    );
  }
}