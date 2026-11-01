import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

final _db = FirebaseFirestore.instance;

class StudentHome extends StatelessWidget {
  final String uid;
  const StudentHome({super.key, required this.uid});

  @override
  Widget build(BuildContext context) => FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _db.collection('students').doc(uid).get(),
        builder: (c, s) {
          if (!s.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
          final st = s.data!.data() ?? {};
          return DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                title: Text(st['name'] ?? 'Eleve'),
                actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut())],
                bottom: const TabBar(tabs: [Tab(text: 'Notes'), Tab(text: 'Suivi'), Tab(text: 'Series')]),
              ),
              body: TabBarView(children: [
                _grades(),
                _daily(),
                _series(st['classId']),
              ]),
            ),
          );
        },
      );

  Widget _grades() => StreamBuilder<QuerySnapshot>(
        stream: _db.collection('grades').where('studentId', isEqualTo: uid).snapshots(),
        builder: (c, s) {
          final bySubject = <String, List<QueryDocumentSnapshot>>{};
          for (final d in s.data?.docs ?? []) {
            bySubject.putIfAbsent(d['subject'], () => []).add(d);
          }
          if (bySubject.isEmpty) return const Center(child: Text('Mazal ma kayn hta note'));
          return ListView(children: [
            for (final e in bySubject.entries)
              Card(
                margin: const EdgeInsets.all(8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(padding: const EdgeInsets.all(12), child: Text(e.key, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  for (final g in e.value) ListTile(dense: true, title: Text(g['type']), trailing: Text('${g['value']}/20', style: const TextStyle(fontWeight: FontWeight.bold))),
                ]),
              ),
          ]);
        },
      );

  Widget _daily() => StreamBuilder<QuerySnapshot>(
        stream: _db.collection('daily').where('studentId', isEqualTo: uid).snapshots(),
        builder: (c, s) {
          final docs = [...?s.data?.docs]..sort((a, b) => b['date'].compareTo(a['date']));
          const lbl = {'present': 'Hadr', 'absent': 'Ghayb', 'late': 'Ta2khir'};
          return ListView(children: [
            for (final d in docs)
              ListTile(
                leading: Icon(d['status'] == 'absent' ? Icons.person_off : d['status'] == 'late' ? Icons.schedule : Icons.check_circle),
                title: Text('${d['date']} - ${lbl[d['status']]}'),
                subtitle: Text('Moucharaka ${d['participation']}/5${(d['note'] ?? '').toString().isEmpty ? '' : '\n${d['note']}'}'),
              ),
          ]);
        },
      );

  Widget _series(String? classId) => StreamBuilder<QuerySnapshot>(
        stream: _db.collection('series').where('classId', isEqualTo: classId).snapshots(),
        builder: (c, s) => ListView(children: [
          for (final d in s.data?.docs ?? [])
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: Text(d['title']), subtitle: Text(d['date']),
              onTap: () => launchUrl(Uri.parse(d['pdfUrl']), mode: LaunchMode.externalApplication),
            ),
        ]),
      );
}
