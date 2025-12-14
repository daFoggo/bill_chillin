import 'package:bill_chillin/core/services/injection_container.dart';
import 'package:bill_chillin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bill_chillin/features/auth/presentation/bloc/auth_state.dart';
import 'package:bill_chillin/features/group_expenses/presentation/pages/group_expenses_page.dart';
import 'package:bill_chillin/features/home/presentation/pages/home_page.dart';
import 'package:bill_chillin/features/home/presentation/bloc/home_bloc.dart';
import 'package:bill_chillin/features/home/presentation/bloc/home_event.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/personal_expenses_bloc.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/personal_expenses_event.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/personal_expenses_state.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/pages/personal_expenses_page.dart';
import 'package:bill_chillin/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bill_chillin/features/main/presentation/widgets/expandable_fab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const PersonalExpensesPage(),
      const SizedBox(),
      const GroupExpensesPage(),
      const ProfilePage(),
    ];
  }

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
    return MultiBlocProvider(
      providers: [
        BlocProvider<PersonalExpensesBloc>(
          create: (context) {
            final authState = context.read<AuthBloc>().state;
            String userId = '';
            if (authState is AuthAuthenticated) {
              userId = authState.user.id;
            }
            return sl<PersonalExpensesBloc>()
              ..add(LoadPersonalExpensesEvent(userId));
          },
        ),
        BlocProvider<HomeBloc>(
          create: (context) {
            final authState = context.read<AuthBloc>().state;
            String userId = '';
            if (authState is AuthAuthenticated) {
              userId = authState.user.id;
            }
            return sl<HomeBloc>()..add(LoadHomeDataEvent(userId));
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          return BlocListener<PersonalExpensesBloc, PersonalExpensesState>(
            listener: (context, state) {
               if (state is PersonalExpensesOperationSuccess) {
                 final authState = context.read<AuthBloc>().state;
                 if (authState is AuthAuthenticated) {
                   context.read<HomeBloc>().add(LoadHomeDataEvent(authState.user.id));
                 }
               }
            },
            child: Scaffold(
              body: _pages[_currentIndex],
              floatingActionButton: ExpandableFab(
                onCreateTransaction: () {
                  if (_currentIndex != 1) {
                    setState(() => _currentIndex = 1);
                  }
                  PersonalExpensesPage.showTransactionBottomSheet(context);
                },
                onScanReceipt: () {
                  // TODO: Navigate to Scan Receipt
                },
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
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
            ),
          );
        },
      ),
    );
  }
}
