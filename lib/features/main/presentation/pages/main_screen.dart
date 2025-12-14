import 'package:bill_chillin/features/group_expenses/presentation/pages/group_expenses_page.dart';
import 'package:bill_chillin/features/home/presentation/pages/home_page.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/pages/personal_expenses_page.dart';
import 'package:bill_chillin/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:bill_chillin/features/main/presentation/widgets/expandable_fab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const PersonalExpensesPage(),
    const SizedBox(),
    const GroupExpensesPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: ExpandableFab(
        onCreateTransaction: () {
          // TODO: Navigate to Create Transaction
        },
        onScanReceipt: () {
          // TODO: Navigate to Scan Receipt
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Personal',
          ),
          NavigationDestination(icon: SizedBox.shrink(), label: ''),
          NavigationDestination(
            icon: Icon(Icons.groups_3_outlined),
            selectedIcon: Icon(Icons.groups_3),
            label: 'Group',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
