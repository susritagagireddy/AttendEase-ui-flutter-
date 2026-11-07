import 'package:flutter/foundation.dart';

import '../models/exam.dart';
import '../utils/storage.dart';

class SyllabusProvider extends ChangeNotifier {
  List<Exam> exams = [];

  SyllabusProvider() {
    _load();
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _load() async {
    try {
      final m = await loadJson('syllabus');
      if (m != null) {
        exams = (m as List).map((e) => Exam.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (_) {}
    notifyListeners();
  }

  void _changed() {
    exams.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
    saveJson('syllabus', exams.map((e) => e.toJson()).toList());
  }

  Exam? get nextExam {
    final upcoming = exams.where((e) => e.daysLeft >= 0).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  void addExam(String name, DateTime date) {
    exams.add(Exam(id: _id(), name: name, date: date));
    _changed();
  }

  void deleteExam(Exam e) {
    exams.removeWhere((x) => x.id == e.id);
    _changed();
  }

  void addChapter(Exam e, String title) {
    e.chapters.add(Chapter(title: title));
    _changed();
  }

  void toggleChapter(Chapter c) {
    c.done = !c.done;
    _changed();
  }

  void deleteChapter(Exam e, Chapter c) {
    e.chapters.remove(c);
    _changed();
  }
}
