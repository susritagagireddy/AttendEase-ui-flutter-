/// One slot in the weekly timetable. Attendance for each date is kept in [marks].
class ClassEntry {
  final String id;
  final String subjectId;
  final int weekday; // 1 = Monday ... 7 = Sunday
  final int minutes; // minutes since midnight
  final Map<String, String> marks; // 'yyyy-MM-dd' -> present | absent | cancelled

  ClassEntry({
    required this.id,
    required this.subjectId,
    required this.weekday,
    required this.minutes,
    Map<String, String>? marks,
  }) : marks = marks ?? {};

  Map<String, dynamic> toJson() => {
        'id': id,
        'subjectId': subjectId,
        'weekday': weekday,
        'minutes': minutes,
        'marks': marks,
      };

  factory ClassEntry.fromJson(Map<String, dynamic> j) => ClassEntry(
        id: j['id'],
        subjectId: j['subjectId'],
        weekday: j['weekday'],
        minutes: j['minutes'],
        marks: Map<String, String>.from(j['marks'] ?? {}),
      );
}
