import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/class_entry.dart';
import '../providers/attendance_provider.dart';
import '../utils/calculations.dart';

class ClassCard extends StatelessWidget {
  final ClassEntry entry;
  final DateTime date;
  final VoidCallback? onDelete;

  const ClassCard({super.key, required this.entry, required this.date, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final att = context.watch<AttendanceProvider>();
    final status = entry.marks[dateKey(date)];

    Widget btn(String label, String value, IconData icon, Color color) {
      final selected = status == value;
      final text = FittedBox(child: Text(label));
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: selected
              ? FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: color),
                  onPressed: () => att.mark(entry, date, value),
                  icon: Icon(icon, size: 18),
                  label: text,
                )
              : OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: color),
                  onPressed: () => att.mark(entry, date, value),
                  icon: Icon(icon, size: 18),
                  label: text,
                ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    att.subjectName(entry.subjectId),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(fmtMinutes(entry.minutes)),
                if (onDelete != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                btn('Present', 'present', Icons.check, Colors.green),
                btn('Absent', 'absent', Icons.close, Colors.red),
                btn('Cancelled', 'cancelled', Icons.block, Colors.blueGrey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
