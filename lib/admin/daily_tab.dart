import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets.dart';

class DailyTab extends StatefulWidget {
  const DailyTab({super.key});
  @override
  State<DailyTab> createState() => _DailyTabState();
}

class _DailyTabState extends State<DailyTab> {
  String? classId;
  DateTime date = DateTime.now();
  List<QueryDocumentSnapshot> students = [];
  final status = <String, String>{};
  final part = <String, int>{};
  final note = <String, TextEditingController>{};

  String get ds => date.toIso8601String().substring(0, 10);

  Future<void> load() async {
    if (classId == null) return;
    final st = await db.collection('students').where('classId', isEqualTo: classId).get();
    final old = await db.collection('daily').where('classId', isEqualTo: classId).where('date', isEqualTo: ds).get();
    final m = {for (final d in old.docs) d['studentId'] as String: d};
    status.clear(); part.clear(); note.clear();
    for (final s in st.docs) {
      status[s.id] = m[s.id]?['status'] ?? 'present';
      part[s.id] = m[s.id]?['participation'] ?? 3;
      note[s.id] = TextEditingController(text: m[s.id]?['note'] ?? '');
    }
    setState(() => students = [...st.docs]..sort((a, b) => a['name'].compareTo(b['name'])));
  }

  Future<void> save() async {
    final b = db.batch();
    for (final s in students) {
      b.set(db.collection('daily').doc('${s.id}_$ds'), {
        'studentId': s.id, 'studentName': s['name'], 'classId': classId, 'date': ds,
        'status': status[s.id], 'participation': part[s.id], 'note': note[s.id]!.text.trim(),
      });
    }
    await b.commit();
    if (mounted) toast(context, 'Tsjl');
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            ClassPicker(value: classId, onChanged: (v) { classId = v; load(); }),
            Row(children: [
              Text(ds), const Spacer(),
              TextButton(onPressed: () async {
                final d = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2024), lastDate: DateTime(2100));
                if (d != null) { date = d; load(); }
              }, child: const Text('Bdl l\'date')),
            ]),
          ]),
        ),
        Expanded(
          child: ListView(children: [
            for (final s in students)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'present', label: Text('Hadr')),
                        ButtonSegment(value: 'absent', label: Text('Ghayb')),
                        ButtonSegment(value: 'late', label: Text('Ta2khir')),
                      ],
                      selected: {status[s.id]!},
                      onSelectionChanged: (v) => setState(() => status[s.id] = v.first),
                    ),
                    Row(children: [
                      const Text('Moucharaka: '),
                      DropdownButton<int>(value: part[s.id], items: [for (var i = 0; i <= 5; i++) DropdownMenuItem(value: i, child: Text('$i/5'))], onChanged: (v) => setState(() => part[s.id] = v!)),
                    ]),
                    TextField(controller: note[s.id], decoration: const InputDecoration(labelText: 'Solok / mola7ada')),
                  ]),
                ),
              ),
          ]),
        ),
        if (students.isNotEmpty)
          Padding(padding: const EdgeInsets.all(12), child: SizedBox(width: double.infinity, child: FilledButton(onPressed: save, child: const Text('Sjl')))),
      ]);
}
