import 'package:bill_chillin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bill_chillin/features/auth/presentation/bloc/auth_event.dart';
import 'package:bill_chillin/features/auth/presentation/pages/auth_page.dart';
import 'package:bill_chillin/features/home/presentation/widgets/balance_card.dart';
import 'package:bill_chillin/features/home/presentation/widgets/home_chart_card.dart';
import 'package:bill_chillin/features/home/presentation/widgets/overview_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock Data
    const double balance = 12500.00;
    const double income = 4500.00;
    const double expense = 1200.00;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOutEvent());
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const AuthPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              const BalanceCard(balance: balance),
              const SizedBox(height: 24),

              // Overview Header + Time Filter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Overview",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  _buildTimeFilter(theme),
                ],
              ),
              const SizedBox(height: 16),

              // Income / Expense Row
              Row(
                children: [
                  OverviewCard(
                    title: "Income",
                    amount: income,
                    icon: Icons.arrow_downward,
                    isIncome: true,
                  ),
                  const SizedBox(width: 16),
                  OverviewCard(
                    title: "Expense",
                    amount: expense,
                    icon: Icons.arrow_upward,
                    isIncome: false,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Chart Section
              const HomeChartCard(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFilter(ThemeData theme) {
    return Chip(
      label: const Text('Weekly'),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.bold,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
