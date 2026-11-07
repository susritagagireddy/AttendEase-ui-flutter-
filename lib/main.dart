import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/attendance_provider.dart';
import 'providers/cgpa_provider.dart';
import 'providers/syllabus_provider.dart';
import 'screens/attendance_screen.dart';
import 'screens/cgpa_screen.dart';
import 'screens/home_screen.dart';
import 'screens/syllabus_screen.dart';
import 'screens/assignments_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => SyllabusProvider()),
        ChangeNotifierProvider(create: (_) => CgpaProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => AssignmentProvider()),
      ],
      child: const AttendEaseApp(),
    ),
  );
}

class AttendEaseApp extends StatelessWidget {
  const AttendEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AttendEase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          AttendanceScreen(),
          SyllabusScreen(),
          AssignmentsScreen(),
          CgpaScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.fact_check_outlined),
              selectedIcon: Icon(Icons.fact_check),
              label: 'Attendance'),
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Syllabus'),
          NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: 'Tasks'),
          NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school),
              label: 'CGPA'),
        ],
      ),
    );
  }
}
