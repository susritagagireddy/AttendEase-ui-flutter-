import 'package:flutter/foundation.dart';

import '../models/class_entry.dart';
import '../models/subject.dart';
import '../utils/calculations.dart';
import '../utils/storage.dart';

class Stats {
  final int attended;
  final int total;
  const Stats(this.attended, this.total);
  double get percent => calcPercent(attended, total);
}

class AttendanceProvider extends ChangeNotifier {
  List<Subject> subjects = [];
  List<ClassEntry> classes = [];
  double target = 75;

  AttendanceProvider() {
    _load();
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _load() async {
    try {
      final m = await loadJson('attendance');
      if (m != null) {
        subjects = (m['subjects'] as List)
            .map((e) => Subject.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        classes = (m['classes'] as List)
            .map((e) => ClassEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        target = (m['target'] as num).toDouble();
      }
    } catch (_) {}
    notifyListeners();
  }

  void _changed() {
    notifyListeners();
    saveJson('attendance', {
      'subjects': subjects.map((s) => s.toJson()).toList(),
      'classes': classes.map((c) => c.toJson()).toList(),
      'target': target,
    });
  }

  String subjectName(String id) => subjects
      .firstWhere((s) => s.id == id, orElse: () => Subject(id: '', name: 'Unknown'))
      .name;

  List<ClassEntry> classesForDay(int weekday) =>
      classes.where((c) => c.weekday == weekday).toList()
        ..sort((a, b) => a.minutes.compareTo(b.minutes));

  Stats _count(Iterable<ClassEntry> list) {
    int attended = 0, total = 0;
    for (final c in list) {
      for (final v in c.marks.values) {
        if (v == 'present') {
          attended++;
          total++;
        } else if (v == 'absent') {
          total++;
        } // 'cancelled' counts for nothing
      }
    }
    return Stats(attended, total);
  }

  Stats statsFor(String subjectId) => _count(classes.where((c) => c.subjectId == subjectId));
  Stats get overall => _count(classes);

  void addSubject(String name) {
    subjects.add(Subject(id: _id(), name: name));
    _changed();
  }

  void deleteSubject(Subject s) {
    subjects.removeWhere((x) => x.id == s.id);
    classes.removeWhere((c) => c.subjectId == s.id);
    _changed();
  }

  void addClass(String subjectId, int weekday, int minutes) {
    classes.add(ClassEntry(id: _id(), subjectId: subjectId, weekday: weekday, minutes: minutes));
    _changed();
  }

  void deleteClass(ClassEntry c) {
    classes.removeWhere((x) => x.id == c.id);
    _changed();
  }

  /// Tapping the same status again clears the mark.
  void mark(ClassEntry c, DateTime date, String status) {
    final k = dateKey(date);
    if (c.marks[k] == status) {
      c.marks.remove(k);
    } else {
      c.marks[k] = status;
    }
    _changed();
  }

  void setTarget(double t) {
    target = t;
    _changed();
  }
}
