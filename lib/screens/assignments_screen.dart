import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/attendance_provider.dart';
import '../utils/calculations.dart';
import '../utils/dialogs.dart';
import '../utils/storage.dart';

// ───────────────────────── Model ─────────────────────────
class Assignment {
  final String id;
  String title;
  String subject; // '' = no subject
  DateTime due;
  bool done;

  Assignment({
    required this.id,
    required this.title,
    required this.subject,
    required this.due,
    this.done = false,
  });

  int get daysLeft {
    final now = DateTime.now();
    return DateTime(due.year, due.month, due.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subject': subject,
        'due': due.toIso8601String(),
        'done': done,
      };

  factory Assignment.fromJson(Map<String, dynamic> j) => Assignment(
        id: j['id'],
        title: j['title'],
        subject: j['subject'] ?? '',
        due: DateTime.parse(j['due']),
        done: j['done'] ?? false,
      );
}

// ───────────────────────── Provider ─────────────────────────
class AssignmentProvider extends ChangeNotifier {
  List<Assignment> items = [];

  AssignmentProvider() {
    _load();
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _load() async {
    try {
      final m = await loadJson('assignments');
      if (m != null) {
        items = (m as List)
            .map((e) => Assignment.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}
    notifyListeners();
  }

  void _changed() {
    notifyListeners();
    saveJson('assignments', items.map((a) => a.toJson()).toList());
  }

  /// Pending assignments, earliest due date first.
  List<Assignment> get pending => items.where((a) => !a.done).toList()
    ..sort((a, b) => a.due.compareTo(b.due));

  List<Assignment> get completed => items.where((a) => a.done).toList()
    ..sort((a, b) => b.due.compareTo(a.due));

  void add(String title, String subject, DateTime due) {
    items.add(Assignment(id: _id(), title: title, subject: subject, due: due));
    _changed();
  }

  void toggle(Assignment a) {
    a.done = !a.done;
    _changed();
  }

  void delete(Assignment a) {
    items.removeWhere((x) => x.id == a.id);
    _changed();
  }
}

// ───────────────────────── Screen ─────────────────────────
class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  int _filter = 0; // 0 = All, 1 = Pending, 2 = Done

  Future<void> _add() async {
    final p = context.read<AssignmentProvider>();
    final subjects =
        context.read<AttendanceProvider>().subjects.map((s) => s.name).toList();
    final titleC = TextEditingController();
    String subject = '';
    DateTime due = DateTime.now().add(const Duration(days: 3));

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('New assignment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleC,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: subject,
                decoration:
                    const InputDecoration(labelText: 'Subject (optional)'),
                items: [
                  const DropdownMenuItem(value: '', child: Text('No subject')),
                  ...subjects
                      .map((s) => DropdownMenuItem(value: s, child: Text(s))),
                ],
                onChanged: (v) => setS(() => subject = v ?? ''),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.event),
                label: Text('Due ${fmtDate(due)}'),
                onPressed: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: due,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                  );
                  if (d != null) setS(() => due = d);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final t = titleC.text.trim();
                if (t.isNotEmpty) p.add(t, subject, due);
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  (String, Color?) _dueLabel(Assignment a) {
    if (a.done) return ('Completed', Colors.green);
    final d = a.daysLeft;
    if (d < 0) return ('Overdue by ${-d} day${d == -1 ? '' : 's'}', Colors.red);
    if (d == 0) return ('Due today', Colors.orange);
    if (d == 1) return ('Due tomorrow', Colors.orange);
    return ('Due in $d days · ${fmtDate(a.due)}', null);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AssignmentProvider>();
    final theme = Theme.of(context);
    final total = p.items.length;
    final done = p.completed.length;

    final List<Assignment> shown = switch (_filter) {
      1 => p.pending,
      2 => p.completed,
      _ => [...p.pending, ...p.completed],
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Add assignment'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    total == 0
                        ? 'No assignments yet'
                        : '${total - done} pending · $done done',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                      value: total == 0 ? 0 : done / total, minHeight: 8),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final (i, label) in ['All', 'Pending', 'Done'].indexed)
                ChoiceChip(
                  label: Text(label),
                  selected: _filter == i,
                  onSelected: (_) => setState(() => _filter = i),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (shown.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Nothing here. Tap "Add assignment" to get started.',
                  textAlign: TextAlign.center),
            ),
          ...shown.map((a) {
            final (label, color) = _dueLabel(a);
            return Card(
              child: ListTile(
                leading: Checkbox(value: a.done, onChanged: (_) => p.toggle(a)),
                title: Text(
                  a.title,
                  style: TextStyle(
                      decoration: a.done ? TextDecoration.lineThrough : null),
                ),
                subtitle: Text(
                  a.subject.isEmpty ? label : '${a.subject} · $label',
                  style: TextStyle(
                      color: color,
                      fontWeight: color == null ? null : FontWeight.w600),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    if (await confirm(context, 'Delete "${a.title}"?'))
                      p.delete(a);
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
