import 'package:flutter/foundation.dart';

import '../models/semester.dart';
import '../utils/storage.dart';

class CgpaProvider extends ChangeNotifier {
  List<Semester> semesters = [];

  CgpaProvider() {
    _load();
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _load() async {
    try {
      final m = await loadJson('cgpa');
      if (m != null) {
        semesters = (m as List).map((e) => Semester.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (_) {}
    notifyListeners();
  }

  void _changed() {
    notifyListeners();
    saveJson('cgpa', semesters.map((s) => s.toJson()).toList());
  }

  double? get cgpa {
    final credits = semesters.fold(0.0, (s, e) => s + e.credits);
    if (credits == 0) return null;
    return semesters.fold(0.0, (s, e) => s + e.points) / credits;
  }

  void addSemester() {
    semesters.add(Semester(id: _id(), name: 'Semester ${semesters.length + 1}'));
    _changed();
  }

  void deleteSemester(Semester s) {
    semesters.removeWhere((x) => x.id == s.id);
    _changed();
  }

  void addCourse(Semester s, Course c) {
    s.courses.add(c);
    _changed();
  }

  void setGrade(Course c, String grade) {
    c.grade = grade;
    _changed();
  }

  void deleteCourse(Semester s, Course c) {
    s.courses.remove(c);
    _changed();
  }
}
