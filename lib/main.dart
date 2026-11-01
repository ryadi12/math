import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'admin/admin_home.dart';
import 'student/student_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.current);
  runApp(const EcoleApp());
}

class EcoleApp extends StatelessWidget {
  const EcoleApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Ecole',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const AuthGate(),
      );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (c, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final u = s.data;
        if (u == null) return const LoginPage();
        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance.collection('users').doc(u.uid).get(),
          builder: (c, r) {
            if (!r.hasData) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            final role = r.data!.data()?['role'];
            if (role == 'admin') return const AdminHome();
            if (role == 'student') return StudentHome(uid: u.uid);
            return Scaffold(
              body: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Compte sans role'),
                  TextButton(onPressed: () => FirebaseAuth.instance.signOut(), child: const Text('Deconnexion')),
                ]),
              ),
            );
          },
        );
      },
    );
  }
}
