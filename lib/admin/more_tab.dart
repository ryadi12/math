import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'widgets.dart';

class MoreTab extends StatefulWidget {
  const MoreTab({super.key});
  @override
  State<MoreTab> createState() => _MoreTabState();
}

class _MoreTabState extends State<MoreTab> {
  String? classId;
  bool uploading = false;

  Future<void> addNote() async {
    final t = await askText(context, 'Daftar: dars / devoir', label: 'Kteb hna');
    if (t == null || t.isEmpty) return;
    await db.collection('notebook').add({'classId': classId, 'content': t, 'date': DateTime.now().toIso8601String().substring(0, 10)});
  }

  Future<void> addPdf() async {
    final title = await askText(context, 'Titre dyal la serie', label: 'Ex: Serie 1 - Fonctions');
    if (title == null || title.isEmpty) return;
    final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], withData: true);
    if (r == null || r.files.single.bytes == null) return;
    setState(() => uploading = true);
    try {
      final ref = FirebaseStorage.instance.ref('series/$classId/${DateTime.now().millisecondsSinceEpoch}.pdf');
      await ref.putData(r.files.single.bytes!, SettableMetadata(contentType: 'application/pdf'));
      await db.collection('series').add({'classId': classId, 'title': title, 'pdfUrl': await ref.getDownloadURL(), 'date': DateTime.now().toIso8601String().substring(0, 10)});
    } catch (e) {
      if (mounted) toast(context, 'Khata: $e');
    }
    if (mounted) setState(() => uploading = false);
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Column(children: [
          Padding(padding: const EdgeInsets.all(12), child: ClassPicker(value: classId, onChanged: (v) => setState(() => classId = v))),
          const TabBar(tabs: [Tab(text: 'Daftar'), Tab(text: 'Series PDF')]),
          Expanded(
            child: classId == null
                ? const Center(child: Text('Khtar classe'))
                : TabBarView(children: [
                    _list('notebook', 'content', addNote, Icons.edit_note),
                    _list('series', 'title', addPdf, Icons.picture_as_pdf),
                  ]),
          ),
        ]),
      );

  Widget _list(String coll, String field, VoidCallback onAdd, IconData icon) => Scaffold(
        floatingActionButton: FloatingActionButton(onPressed: uploading ? null : onAdd, child: uploading ? const CircularProgressIndicator() : const Icon(Icons.add)),
        body: StreamBuilder<QuerySnapshot>(
          stream: db.collection(coll).where('classId', isEqualTo: classId).snapshots(),
          builder: (c, s) {
            final docs = [...?s.data?.docs]..sort((a, b) => b['date'].compareTo(a['date']));
            return ListView(children: [
              for (final d in docs)
                ListTile(
                  leading: Icon(icon), title: Text(d[field]), subtitle: Text(d['date']),
                  trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () async { if (await confirm(context, 'Msah?')) d.reference.delete(); }),
                ),
            ]);
          },
        ),
      );
}
