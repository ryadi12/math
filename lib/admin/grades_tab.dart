import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets.dart';

class GradesTab extends StatefulWidget {
  const GradesTab({super.key});
  @override
  State<GradesTab> createState() => _GradesTabState();
}

class _GradesTabState extends State<GradesTab> {
  String? classId;
  String type = gradeTypes.first;
  final subject = TextEditingController();
  List<QueryDocumentSnapshot> students = [];
  final ctrls = <String, TextEditingController>{};

  Future<void> load() async {
    if (classId == null || subject.text.trim().isEmpty) return toast(context, 'Khtar classe o kteb lmadda');
    final st = await db.collection('students').where('classId', isEqualTo: classId).get();
    final gr = await db.collection('grades')
        .where('classId', isEqualTo: classId)
        .where('subject', isEqualTo: subject.text.trim())
        .where('type', isEqualTo: type)
        .get();
    final byStudent = {for (final g in gr.docs) g['studentId'] as String: g['value']};
    ctrls.clear();
    for (final s in st.docs) {
      ctrls[s.id] = TextEditingController(text: byStudent[s.id]?.toString() ?? '');
    }
    setState(() => students = [...st.docs]..sort((a, b) => a['name'].compareTo(b['name'])));
  }

  Future<void> save() async {
    final b = db.batch();
    final subj = subject.text.trim();
    for (final s in students) {
      final txt = ctrls[s.id]!.text.trim().replaceAll(',', '.');
      final ref = db.collection('grades').doc('${s.id}_${subj}_$type');
      if (txt.isEmpty) {
        b.delete(ref);
      } else {
        final v = double.tryParse(txt);
        if (v == null) return toast(context, 'Note ghalta: ${s['name']}');
        b.set(ref, {'studentId': s.id, 'studentName': s['name'], 'classId': classId, 'subject': subj, 'type': type, 'value': v, 'date': DateTime.now().toIso8601String().substring(0, 10)});
      }
    }
    await b.commit();
    if (mounted) toast(context, 'Notes tsjlo');
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            ClassPicker(value: classId, onChanged: (v) => setState(() { classId = v; students = []; })),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextField(controller: subject, decoration: const InputDecoration(labelText: 'Madda', border: OutlineInputBorder()))),
              const SizedBox(width: 8),
              DropdownButton<String>(value: type, items: [for (final t in gradeTypes) DropdownMenuItem(value: t, child: Text(t))], onChanged: (v) => setState(() { type = v!; students = []; })),
            ]),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: OutlinedButton(onPressed: load, child: const Text('Afficher'))),
          ]),
        ),
        Expanded(
          child: ListView(children: [
            for (final s in students)
              ListTile(
                title: Text(s['name']),
                trailing: SizedBox(width: 80, child: TextField(controller: ctrls[s.id], keyboardType: const TextInputType.numberWithOptions(decimal: true), textAlign: TextAlign.center, decoration: const InputDecoration(hintText: '/20'))),
              ),
          ]),
        ),
        if (students.isNotEmpty)
          Padding(padding: const EdgeInsets.all(12), child: SizedBox(width: double.infinity, child: FilledButton(onPressed: save, child: const Text('Sjl les notes')))),
      ]);
}
