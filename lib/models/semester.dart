const gradePoints = <String, double>{
  'O': 10, 'A+': 9, 'A': 8, 'B+': 7, 'B': 6, 'C': 5, 'F': 0,
};

class Course {
  String name;
  double credits;
  String grade;

  Course({required this.name, required this.credits, required this.grade});

  Map<String, dynamic> toJson() => {'name': name, 'credits': credits, 'grade': grade};

  factory Course.fromJson(Map<String, dynamic> j) => Course(
        name: j['name'],
        credits: (j['credits'] as num).toDouble(),
        grade: j['grade'],
      );
}

class Semester {
  final String id;
  String name;
  List<Course> courses;

  Semester({required this.id, required this.name, List<Course>? courses})
      : courses = courses ?? [];

  double get credits => courses.fold(0.0, (s, c) => s + c.credits);
  double get points => courses.fold(0.0, (s, c) => s + c.credits * (gradePoints[c.grade] ?? 0));
  double? get sgpa => credits == 0 ? null : points / credits;

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'courses': courses.map((c) => c.toJson()).toList()};

  factory Semester.fromJson(Map<String, dynamic> j) => Semester(
        id: j['id'],
        name: j['name'],
        courses: (j['courses'] as List)
            .map((e) => Course.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}
