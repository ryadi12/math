import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';
import 'widgets.dart';

class StudentsTab extends StatefulWidget {
  const StudentsTab({super.key});
  @override
  State<StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  String? classId;

  Future<void> addStudent() async {
    final name = TextEditingController(), code = TextEditingController(), pw = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tilmid jdid'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Smiya kamla')),
          TextField(controller: code, decoration: const InputDecoration(labelText: 'Code (massar)')),
          TextField(controller: pw, decoration: const InputDecoration(labelText: 'Mot de passe (6+)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Zid')),
        ],
      ),
    );
    if (ok != true) return;
    FirebaseApp? app;
    try {
      app = await Firebase.initializeApp(name: 'sec', options: DefaultFirebaseOptions.current);
      final a = FirebaseAuth.instanceFor(app: app);
      final cred = await a.createUserWithEmailAndPassword(email: '${code.text.trim()}@ecole.app', password: pw.text);
      final uid = cred.user!.uid;
      await a.signOut();
      final b = db.batch();
      b.set(db.collection('users').doc(uid), {'role': 'student'});
      b.set(db.collection('students').doc(uid), {'name': name.text.trim(), 'code': code.text.trim(), 'classId': classId});
      await b.commit();
      if (mounted) toast(context, 'Tilmid tzad');
    } catch (e) {
      if (mounted) toast(context, 'Khata: $e');
    } finally {
      await app?.delete();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: classId == null
            ? null
            : FloatingActionButton(onPressed: addStudent, child: const Icon(Icons.person_add)),
        body: Column(children: [
          Padding(padding: const EdgeInsets.all(12), child: ClassPicker(value: classId, onChanged: (v) => setState(() => classId = v))),
          Expanded(
            child: classId == null
                ? const Center(child: Text('Khtar classe'))
                : StreamBuilder<QuerySnapshot>(
                    stream: db.collection('students').where('classId', isEqualTo: classId).snapshots(),
                    builder: (c, s) {
                      final docs = [...?s.data?.docs]..sort((a, b) => a['name'].compareTo(b['name']));
                      return ListView(children: [
                        for (final d in docs)
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(d['name']),
                            subtitle: Text('Code: ${d['code']}'),
                            trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                              if (await confirm(context, 'Msah tilmid?')) {
                                await d.reference.delete();
                                await db.collection('users').doc(d.id).delete();
                              }
                            }),
                          ),
                      ]);
                    },
                  ),
          ),
        ]),
      );
}
