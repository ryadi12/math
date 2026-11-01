import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets.dart';

class ClassesTab extends StatelessWidget {
  const ClassesTab({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            final n = await askText(context, 'Classe jdida', label: 'Smiya (ex: 3AC1)');
            if (n != null && n.isNotEmpty) await db.collection('classes').add({'name': n});
          },
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: db.collection('classes').orderBy('name').snapshots(),
          builder: (c, s) => ListView(children: [
            for (final d in s.data?.docs ?? [])
              ListTile(
                title: Text(d['name']),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () async {
                    final n = await askText(context, 'Bdl smiya', label: d['name']);
                    if (n != null && n.isNotEmpty) await d.reference.update({'name': n});
                  }),
                  IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                    if (await confirm(context, 'Msah had classe?')) await d.reference.delete();
                  }),
                ]),
              ),
          ]),
        ),
      );
}
