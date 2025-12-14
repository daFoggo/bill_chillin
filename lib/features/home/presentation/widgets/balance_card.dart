import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final String currency;

  const BalanceCard({super.key, required this.balance, this.currency = 'VND'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock Data for Budget Distribution
    final budgets = [
      {'name': 'Housing', 'amount': 0.4, 'color': theme.colorScheme.primary},
      {
        'name': 'Food',
        'amount': 0.3,
        'color': theme.colorScheme.onPrimaryContainer,
      },
      {'name': 'Transport', 'amount': 0.1, 'color': theme.colorScheme.tertiary},
      {
        'name': 'Other',
        'amount': 0.2,
        'color': theme.colorScheme.onTertiaryContainer,
      },
    ];

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
              NumberFormat.currency(
                locale: 'vi_VN',
                symbol: currency,
              ).format(balance),
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Mini Budget Distribution Chart (Custom Horizontal Bar)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Monthly Budget Distribution",
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
                        return Expanded(
                          flex: ((budget['amount'] as double) * 100).toInt(),
                          child: Container(color: budget['color'] as Color),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Legend
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
        ),
      ),
    );
  }
}
