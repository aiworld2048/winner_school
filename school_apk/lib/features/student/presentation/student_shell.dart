import 'package:flutter/material.dart';

import '../../dictionary/presentation/dictionary_screen.dart';
import '../../media/presentation/media_hub_screen.dart';
import '../../shared/widgets/app_navbar.dart';
import '../../student_notes/presentation/student_notes_screen.dart';
import 'screens/student_calculator_screen.dart';
import 'screens/student_essays_screen.dart';
import 'screens/student_exams_screen.dart';
import 'screens/student_lessons_screen.dart';
import 'screens/student_profile_screen.dart';
import 'screens/student_wallet_screen.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;

  void _navigate(int index) {
    Navigator.of(context).maybePop();
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const StudentLessonsScreen(),
      const StudentWalletScreen(),
      const StudentProfileScreen(),
      const StudentCalculatorScreen(),
    ];

    final titles = ['Lessons', 'Wallet', 'Profile', 'Calculator'];

    return Scaffold(
      drawer: _StudentDrawer(
        currentIndex: _index,
        onTap: _navigate,
      ),
      appBar: AppNavbar(
        title: titles[_index],
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
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
          NavigationDestination(icon: Icon(Icons.calculate_outlined), label: 'Calc'),
        ],
        onDestinationSelected: (value) => setState(() => _index = value),
      ),
    );
  }
}

class _StudentDrawer extends StatelessWidget {
  const _StudentDrawer({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              title: Text(
                'Winner School',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              subtitle: Text('Student portal'),
            ),
            const Divider(),
            _DrawerTile(
              icon: Icons.menu_book,
              label: 'Lessons',
              selected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _DrawerTile(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Wallet',
              selected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _DrawerTile(
              icon: Icons.person_outline,
              label: 'Profile',
              selected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            _DrawerTile(
              icon: Icons.calculate_outlined,
              label: 'Calculator',
              selected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.newspaper_outlined),
              title: const Text('Media hub'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MediaHubScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Dictionary'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DictionaryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Notebook'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StudentNotesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.quiz_outlined),
              title: const Text('Exams'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StudentExamsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('Essays'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StudentEssaysScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: selected ? Theme.of(context).colorScheme.primary : null),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      onTap: onTap,
    );
  }
}
