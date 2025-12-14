import 'package:bill_chillin/core/util/currency_util.dart';
import 'package:flutter/material.dart';

class TotalBalanceWidget extends StatelessWidget {
  final double totalBalance;

  const TotalBalanceWidget({super.key, required this.totalBalance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedBalance = CurrencyUtil.format(totalBalance);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            "Total Balance",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formattedBalance,
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
