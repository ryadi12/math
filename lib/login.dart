import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final id = TextEditingController();
  final pw = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> login() async {
    setState(() { loading = true; error = null; });
    final v = id.text.trim();
    final email = v.contains('@') ? v : '$v@ecole.app';
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pw.text);
    } on FirebaseAuthException {
      setState(() => error = 'Code ou mot de passe incorrect');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(children: [
                const Icon(Icons.school, size: 72),
                const SizedBox(height: 16),
                TextField(controller: id, decoration: const InputDecoration(labelText: 'Code eleve / email admin', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: pw, obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe', border: OutlineInputBorder())),
                if (error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(error!, style: const TextStyle(color: Colors.red))),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: FilledButton(onPressed: loading ? null : login, child: Text(loading ? '...' : 'Connexion'))),
              ]),
            ),
          ),
        ),
      );
}
