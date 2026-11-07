double calcPercent(int attended, int total) =>
    total == 0 ? 100.0 : attended / total * 100;

/// How many consecutive classes must be attended to reach [target] %.
int classesNeeded(int attended, int total, double target) {
  final t = (target / 100).clamp(0.0, 0.99);
  if (total == 0 || attended / total >= t) return 0;
  final n = ((t * total - attended) / (1 - t) - 1e-9).ceil();
  return n < 0 ? 0 : n;
}

/// How many classes can be skipped while staying at or above [target] %.
int classesCanSkip(int attended, int total, double target) {
  final t = (target / 100).clamp(0.01, 1.0);
  if (total == 0) return 0;
  final n = (attended / t - total + 1e-9).floor();
  return n < 0 ? 0 : n;
}

String attendanceAdvice(int attended, int total, double target) {
  if (total == 0) return 'Add your timetable and start marking classes.';
  if (attended / total * 100 >= target) {
    final n = classesCanSkip(attended, total, target);
    if (n == 0) return "You're right at the limit. Don't skip the next class!";
    return 'You can safely skip $n more class${n == 1 ? '' : 'es'}.';
  }
  final n = classesNeeded(attended, total, target);
  return 'Below ${target.round()}%! Attend the next $n class${n == 1 ? '' : 'es'} in a row to recover.';
}

const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String fmtDate(DateTime d) => '${d.day} ${monthNames[d.month - 1]} ${d.year}';

String fmtMinutes(int m) {
  final h = m ~/ 60;
  final mm = m % 60;
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${mm.toString().padLeft(2, '0')} ${h < 12 ? 'AM' : 'PM'}';
}

/// Date of the given weekday (1 = Mon) in the current week.
DateTime dateForWeekday(int weekday) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return today.add(Duration(days: weekday - now.weekday));
}
