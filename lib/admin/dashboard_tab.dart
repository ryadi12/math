import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  Widget stat(String label, String coll, IconData icon, {Query? q}) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<AggregateQuerySnapshot>(
              future: (q ?? db.collection(coll)).count().get(),
              builder: (c, s) => Column(children: [
                Icon(icon, size: 32),
                Text('${s.data?.count ?? '-'}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                Text(label),
              ]),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return ListView(padding: const EdgeInsets.all(12), children: [
      Row(children: [
        stat('Classes', 'classes', Icons.class_),
        stat('Tlamd', 'students', Icons.people),
      ]),
      Row(children: [
        stat('Notes', 'grades', Icons.grade),
        stat('Ghiyab lyoum', 'daily', Icons.person_off,
            q: db.collection('daily').where('date', isEqualTo: today).where('status', isEqualTo: 'absent')),
      ]),
      const Padding(padding: EdgeInsets.all(8), child: Text('Dernieres absences', style: TextStyle(fontWeight: FontWeight.bold))),
      StreamBuilder<QuerySnapshot>(
        stream: db.collection('daily').where('status', isEqualTo: 'absent').orderBy('date', descending: true).limit(10).snapshots(),
        builder: (c, s) => Column(children: [
          for (final d in s.data?.docs ?? [])
            ListTile(dense: true, leading: const Icon(Icons.person_off), title: Text(d['studentName'] ?? ''), subtitle: Text(d['date'])),
        ]),
      ),
    ]);
  }
}
