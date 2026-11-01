import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;

class ClassPicker extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const ClassPicker({super.key, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot>(
        stream: db.collection('classes').orderBy('name').snapshots(),
        builder: (c, s) {
          final docs = s.data?.docs ?? [];
          return DropdownButtonFormField<String>(
            value: docs.any((d) => d.id == value) ? value : null,
            decoration: const InputDecoration(labelText: 'Classe', border: OutlineInputBorder()),
            items: [for (final d in docs) DropdownMenuItem(value: d.id, child: Text(d['name']))],
            onChanged: onChanged,
          );
        },
      );
}

Future<String?> askText(BuildContext context, String title, {String label = ''}) {
  final c = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(controller: c, autofocus: true, decoration: InputDecoration(labelText: label)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('OK')),
      ],
    ),
  );
}

Future<bool> confirm(BuildContext context, String msg) async =>
    (await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Non')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Oui')),
        ],
      ),
    )) ?? false;

void toast(BuildContext c, String m) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));

const gradeTypes = ['Controle 1', 'Controle 2', 'Controle 3', 'Devoir', 'Examen'];
