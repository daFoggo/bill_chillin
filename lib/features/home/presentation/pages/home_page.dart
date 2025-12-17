import 'package:bill_chillin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bill_chillin/features/auth/presentation/bloc/auth_state.dart';
import 'package:bill_chillin/features/home/presentation/widgets/balance_card.dart';
import 'package:bill_chillin/features/home/presentation/widgets/distribution_chart_card.dart';
import 'package:bill_chillin/features/home/presentation/widgets/financial_trend_chart_card.dart';
import 'package:bill_chillin/features/home/presentation/widgets/overview_cards.dart';
import 'package:bill_chillin/features/home/presentation/bloc/home_bloc.dart';
import 'package:bill_chillin/features/home/presentation/bloc/home_state.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String userName = 'User';
            if (state is AuthAuthenticated &&
                state.user.name != null &&
                state.user.name!.isNotEmpty) {
              userName = state.user.name!;
            }
            return Text(
              "Hello, $userName!",
              style: const TextStyle(fontWeight: FontWeight.bold),
            );
          },
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String? avatarUrl;
                if (state is AuthAuthenticated) {
                  avatarUrl = state.user.avatarUrl;
                }

                return GestureDetector(
                  onTap: () {
                    // Navigate to profile or show menu if needed
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl == null
                        ? const Icon(Icons.person, size: 20)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          double balance = 0;
          double income = 0;
          double expense = 0;

          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeLoaded) {
            balance = state.totalBalance;
            income = state.totalIncome;
            expense = state.totalExpense;
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Card
                  BalanceCard(
                    balance: balance,
                    distribution: state is HomeLoaded
                        ? state.categoryDistribution
                        : [],
                  ),
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
                  if (state is HomeLoaded) ...[
                    DistributionChartCard(
                      expenseDistribution: state.expenseDistribution,
                      incomeDistribution: state.incomeDistribution,
                    ),
                    const SizedBox(height: 16),
                    FinancialTrendChartCard(
                      monthlyExpenseTrends: state.monthlyExpenseTrends,
                      monthlyIncomeTrends: state.monthlyIncomeTrends,
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
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
