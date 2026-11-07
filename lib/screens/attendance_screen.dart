import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/attendance_provider.dart';
import '../utils/calculations.dart';
import '../utils/dialogs.dart';
import '../widgets/attendance_ring.dart';
import '../widgets/class_card.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int _day = DateTime.now().weekday - 1; // 0 = Mon

  Future<void> _addSubject() async {
    final att = context.read<AttendanceProvider>();
    final name = await askText(context, 'New subject', 'e.g. Mathematics');
    if (name != null && name.isNotEmpty) att.addSubject(name);
  }

  Future<void> _addClass() async {
    final att = context.read<AttendanceProvider>();
    if (att.subjects.isEmpty) {
      await _addSubject();
      return;
    }
    String subjectId = att.subjects.first.id;
    TimeOfDay time = const TimeOfDay(hour: 9, minute: 0);
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Add class on ${weekdayNames[_day]}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: subjectId,
                items: att.subjects
                    .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged: (v) => setS(() => subjectId = v!),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.access_time),
                label: Text(fmtMinutes(time.hour * 60 + time.minute)),
                onPressed: () async {
                  final t = await showTimePicker(context: ctx, initialTime: time);
                  if (t != null) setS(() => time = t);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                att.addClass(subjectId, _day + 1, time.hour * 60 + time.minute);
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setTarget() async {
    final att = context.read<AttendanceProvider>();
    double value = att.target;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Attendance target'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${value.round()}%', style: Theme.of(ctx).textTheme.headlineMedium),
              Slider(
                value: value,
                min: 50,
                max: 95,
                divisions: 9,
                label: '${value.round()}%',
                onChanged: (v) => setS(() => value = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                att.setTarget(value);
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final att = context.watch<AttendanceProvider>();
    final theme = Theme.of(context);
    final date = dateForWeekday(_day + 1);
    final dayClasses = att.classesForDay(_day + 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(tooltip: 'Add subject', icon: const Icon(Icons.library_add_outlined), onPressed: _addSubject),
          IconButton(tooltip: 'Set target %', icon: const Icon(Icons.tune), onPressed: _setTarget),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addClass,
        icon: const Icon(Icons.add),
        label: const Text('Add class'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(weekdayNames[i]),
                    selected: _day == i,
                    onSelected: (_) => setState(() => _day = i),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Text('${weekdayNames[_day]}, ${fmtDate(date)}', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          if (dayClasses.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No classes on this day. Tap "Add class" to build your timetable.'),
              ),
            )
          else
            ...dayClasses.map(
              (c) => ClassCard(
                entry: c,
                date: date,
                onDelete: () async {
                  if (await confirm(context, 'Delete this class and its attendance records?')) {
                    att.deleteClass(c);
                  }
                },
              ),
            ),
          const SizedBox(height: 20),
          Text('Subject-wise (target ${att.target.round()}%)', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          if (att.subjects.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No subjects yet. Use the top-right button to add one.'),
              ),
            ),
          ...att.subjects.map((s) {
            final st = att.statsFor(s.id);
            final color = st.total == 0 ? Colors.grey : statusColor(st.percent, att.target);
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(s.name, style: theme.textTheme.titleMedium)),
                        Text(
                          st.total == 0 ? '--' : '${st.attended}/${st.total} · ${st.percent.toStringAsFixed(1)}%',
                          style: TextStyle(fontWeight: FontWeight.bold, color: color),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            if (await confirm(context, 'Delete "${s.name}" and all its classes?')) {
                              att.deleteSubject(s);
                            }
                          },
                        ),
                      ],
                    ),
                    LinearProgressIndicator(
                      value: st.total == 0 ? 0 : (st.percent / 100).clamp(0.0, 1.0),
                      color: color,
                      minHeight: 6,
                    ),
                    const SizedBox(height: 6),
                    Text(attendanceAdvice(st.attended, st.total, att.target), style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
