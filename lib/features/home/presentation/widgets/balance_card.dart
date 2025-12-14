import 'package:bill_chillin/core/util/currency_util.dart';
import 'package:bill_chillin/features/home/presentation/bloc/home_state.dart';
import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final String currency;
  final List<CategoryDistribution> distribution;

  const BalanceCard({
    super.key,
    required this.balance,
    this.currency = 'VND',
    this.distribution = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Color palette for dynamic mapping
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.tertiary,
      theme.colorScheme.secondary,
      theme.colorScheme.error,
    ];

    final budgets = distribution.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return {
        'name': item.categoryName,
        'amount': item.percentage,
        'color': colors[index % colors.length],
      };
    }).toList();

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Balance",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyUtil.format(balance),
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (budgets.isNotEmpty) ...[
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Monthly Expenses Distribution",
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 12,
                      child: Row(
                        children: budgets.map((budget) {
                          final flex = ((budget['amount'] as double) * 100)
                              .toInt();
                          return Expanded(
                            flex: flex > 0 ? flex : 1, // Ensure at least 1
                            child: Container(color: budget['color'] as Color),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: budgets.map((budget) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: budget['color'] as Color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            budget['name'] as String,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
