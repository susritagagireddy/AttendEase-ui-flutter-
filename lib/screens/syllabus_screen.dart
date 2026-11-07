import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exam.dart';
import '../providers/syllabus_provider.dart';
import '../utils/calculations.dart';
import '../utils/dialogs.dart';

class SyllabusScreen extends StatelessWidget {
  const SyllabusScreen({super.key});

  Future<void> _addExam(BuildContext context) async {
    final syl = context.read<SyllabusProvider>();
    final nameC = TextEditingController();
    DateTime date = DateTime.now().add(const Duration(days: 7));
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('New exam'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Subject / exam name'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.event),
                label: Text(fmtDate(date)),
                onPressed: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: date,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                  );
                  if (d != null) setS(() => date = d);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final n = nameC.text.trim();
                if (n.isNotEmpty) syl.addExam(n, date);
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final syl = context.watch<SyllabusProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Syllabus')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addExam(context),
        icon: const Icon(Icons.add),
        label: const Text('Add exam'),
      ),
      body: syl.exams.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No exams yet.\nTap "Add exam" to plan your syllabus.', textAlign: TextAlign.center),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: syl.exams.map((e) => _ExamCard(exam: e)).toList(),
            ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final Exam exam;
  const _ExamCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    final syl = context.read<SyllabusProvider>();
    final theme = Theme.of(context);
    final d = exam.daysLeft;
    final label = d < 0 ? 'Exam over' : (d == 0 ? 'Today!' : '$d days left');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exam.name, style: theme.textTheme.titleLarge),
                      Text('${fmtDate(exam.date)} · $label'),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    if (await confirm(context, 'Delete "${exam.name}" and its chapters?')) {
                      syl.deleteExam(exam);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: exam.progress, minHeight: 8),
            const SizedBox(height: 4),
            Text('${(exam.progress * 100).round()}% complete'),
            ...exam.chapters.map(
              (c) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: c.done,
                onChanged: (_) => syl.toggleChapter(c),
                title: Text(
                  c.title,
                  style: TextStyle(decoration: c.done ? TextDecoration.lineThrough : null),
                ),
                secondary: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => syl.deleteChapter(exam, c),
                ),
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add chapter / topic'),
              onPressed: () async {
                final t = await askText(context, 'New chapter', 'e.g. Unit 1: Normalization');
                if (t != null && t.isNotEmpty) syl.addChapter(exam, t);
              },
            ),
          ],
        ),
      ),
    );
  }
}
