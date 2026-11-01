import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_tab.dart';
import 'classes_tab.dart';
import 'students_tab.dart';
import 'grades_tab.dart';
import 'daily_tab.dart';
import 'more_tab.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});
  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int i = 0;
  static const titles = ['Dashboard', 'Classes', 'Tlamd', 'Notes', 'Suivi', 'Cahier / PDF'];
  @override
  Widget build(BuildContext context) {
    final pages = const [DashboardTab(), ClassesTab(), StudentsTab(), GradesTab(), DailyTab(), MoreTab()];
    return Scaffold(
      appBar: AppBar(title: Text(titles[i]), actions: [
        IconButton(icon: const Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut()),
      ]),
      body: pages[i],
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (v) => setState(() => i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.class_), label: 'Classes'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Tlamd'),
          NavigationDestination(icon: Icon(Icons.grade), label: 'Notes'),
          NavigationDestination(icon: Icon(Icons.fact_check), label: 'Suivi'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Plus'),
        ],
      ),
    );
  }
}
