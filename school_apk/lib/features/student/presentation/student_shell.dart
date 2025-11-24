import 'package:flutter/material.dart';

import 'screens/student_lessons_screen.dart';
import 'screens/student_wallet_screen.dart';
import 'screens/student_profile_screen.dart';
import '../../media/presentation/media_hub_screen.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const StudentLessonsScreen(),
      const StudentWalletScreen(),
      const StudentProfileScreen(),
    ];

    final titles = ['Lessons', 'Wallet', 'Profile'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign_outlined),
            tooltip: 'School updates',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MediaHubScreen()),
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: pages[_index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Lessons'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        onDestinationSelected: (value) => setState(() => _index = value),
      ),
    );
  }
}
