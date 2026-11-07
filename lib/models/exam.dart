class Chapter {
  String title;
  bool done;

  Chapter({required this.title, this.done = false});

  Map<String, dynamic> toJson() => {'title': title, 'done': done};

  factory Chapter.fromJson(Map<String, dynamic> j) =>
      Chapter(title: j['title'], done: j['done'] ?? false);
}

class Exam {
  final String id;
  String name;
  DateTime date;
  List<Chapter> chapters;

  Exam({required this.id, required this.name, required this.date, List<Chapter>? chapters})
      : chapters = chapters ?? [];

  double get progress =>
      chapters.isEmpty ? 0 : chapters.where((c) => c.done).length / chapters.length;

  int get daysLeft {
    final now = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date.toIso8601String(),
        'chapters': chapters.map((c) => c.toJson()).toList(),
      };

  factory Exam.fromJson(Map<String, dynamic> j) => Exam(
        id: j['id'],
        name: j['name'],
        date: DateTime.parse(j['date']),
        chapters: (j['chapters'] as List)
            .map((e) => Chapter.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}
