import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/semester.dart';
import '../providers/cgpa_provider.dart';
import '../utils/dialogs.dart';

class CgpaScreen extends StatelessWidget {
  const CgpaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CgpaProvider>();
    final theme = Theme.of(context);
    final cgpa = p.cgpa;

    return Scaffold(
      appBar: AppBar(title: const Text('CGPA Calculator')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: p.addSemester,
        icon: const Icon(Icons.add),
        label: const Text('Add semester'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('Overall CGPA', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    cgpa == null ? '--' : cgpa.toStringAsFixed(2),
                    style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (p.semesters.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Add a semester, then add your subjects with credits and grades.', textAlign: TextAlign.center),
            ),
          ...p.semesters.map((s) => _SemesterCard(sem: s)),
        ],
      ),
    );
  }
}

class _SemesterCard extends StatelessWidget {
  final Semester sem;
  const _SemesterCard({required this.sem});

  Future<void> _addCourse(BuildContext context) async {
    final p = context.read<CgpaProvider>();
    final nameC = TextEditingController();
    final creditC = TextEditingController(text: '3');
    String grade = 'A';
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add subject'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameC, autofocus: true, decoration: const InputDecoration(labelText: 'Subject name')),
              TextField(
                controller: creditC,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Credits'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: grade,
                decoration: const InputDecoration(labelText: 'Grade'),
                items: gradePoints.keys.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setS(() => grade = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final credits = double.tryParse(creditC.text.trim()) ?? 0;
                if (nameC.text.trim().isNotEmpty && credits > 0) {
                  p.addCourse(sem, Course(name: nameC.text.trim(), credits: credits, grade: grade));
                  Navigator.pop(ctx);
                }
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
    final p = context.read<CgpaProvider>();
    final theme = Theme.of(context);
    final sgpa = sem.sgpa;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(sem.name, style: theme.textTheme.titleLarge)),
                Text(
                  'SGPA ${sgpa == null ? '--' : sgpa.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    if (await confirm(context, 'Delete ${sem.name}?')) p.deleteSemester(sem);
                  },
                ),
              ],
            ),
            ...sem.courses.map(
              (c) => Row(
                children: [
                  Expanded(child: Text(c.name)),
                  Text('${c.credits % 1 == 0 ? c.credits.toInt() : c.credits} cr'),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: c.grade,
                    items: gradePoints.keys.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (v) => p.setGrade(c, v!),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => p.deleteCourse(sem, c),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add subject'),
              onPressed: () => _addCourse(context),
            ),
          ],
        ),
      ),
    );
  }
}
