import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/attendance_provider.dart';
import '../providers/syllabus_provider.dart';
import '../utils/calculations.dart';
import '../widgets/attendance_ring.dart';
import '../widgets/class_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final att = context.watch<AttendanceProvider>();
    final syl = context.watch<SyllabusProvider>();
    final o = att.overall;
    final now = DateTime.now();
    final today = att.classesForDay(now.weekday);
    final exam = syl.nextExam;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('AttendEase')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${weekdayNames[now.weekday - 1]}, ${fmtDate(now)}', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('Overall attendance', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  AttendanceRing(percent: o.percent, target: att.target, hasData: o.total > 0),
                  const SizedBox(height: 12),
                  Text('${o.attended} / ${o.total} classes attended'),
                  const SizedBox(height: 8),
                  Text(
                    attendanceAdvice(o.attended, o.total, att.target),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: o.total == 0 ? null : statusColor(o.percent, att.target),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text("Today's classes", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          if (today.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No classes scheduled today. Build your timetable in the Attendance tab.'),
              ),
            )
          else
            ...today.map((c) => ClassCard(entry: c, date: DateTime(now.year, now.month, now.day))),
          const SizedBox(height: 16),
          Text('Next exam', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: exam == null
                  ? const Text('No upcoming exams. Add one in the Syllabus tab.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${exam.name} · ${exam.daysLeft == 0 ? 'Today!' : '${exam.daysLeft} days left'}',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: exam.progress, minHeight: 8),
                        const SizedBox(height: 4),
                        Text('Syllabus ${(exam.progress * 100).round()}% complete'),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
