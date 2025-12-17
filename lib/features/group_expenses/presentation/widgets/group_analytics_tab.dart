import 'package:bill_chillin/features/group_expenses/presentation/bloc/group_detail/group_detail_bloc.dart';
import 'package:bill_chillin/features/home/presentation/bloc/home_state.dart';
import 'package:bill_chillin/features/home/presentation/widgets/distribution_chart_card.dart';
import 'package:bill_chillin/features/home/presentation/widgets/financial_trend_chart_card.dart';
import 'package:flutter/material.dart';

class GroupAnalyticsTab extends StatelessWidget {
  final GroupDetailLoaded state;

  const GroupAnalyticsTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // 1. Filter out settlements
    final validTransactions = state.transactions
        .where((tx) => tx.type != 'settlement')
        .toList();

    // 2. Calculate Total Balance (Expenses)
    final totalBalance = validTransactions.fold(
      0.0,
      (sum, tx) => sum + tx.amount,
    );

    // 3. Calculate Monthly Trends
    final Map<int, double> monthlyExpenseTrends = {};
    for (var tx in validTransactions) {
      final month = tx.date.month;
      monthlyExpenseTrends[month] =
          (monthlyExpenseTrends[month] ?? 0) + tx.amount;
    }

    // 4. Calculate Distribution
    final Map<String, double> categoryMap = {};
    for (var tx in validTransactions) {
      final key = tx.categoryName;
      categoryMap[key] = (categoryMap[key] ?? 0) + tx.amount;
    }

    final List<CategoryDistribution> distribution = [];
    if (totalBalance > 0) {
      categoryMap.forEach((name, amount) {
        distribution.add(
          CategoryDistribution(
            categoryName: name,
            totalAmount: amount,
            percentage: amount / totalBalance,
          ),
        );
      });
      // Sort by percentage descending
      distribution.sort((a, b) => b.percentage.compareTo(a.percentage));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DistributionChartCard(
            expenseDistribution: distribution,
            incomeDistribution: const [],
          ),
          const SizedBox(height: 16),
          FinancialTrendChartCard(
            monthlyExpenseTrends: monthlyExpenseTrends,
            monthlyIncomeTrends: const {},
          ),
        ],
      ),
    );
  }
}
