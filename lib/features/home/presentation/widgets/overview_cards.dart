import 'package:bill_chillin/core/util/currency_util.dart';
import 'package:flutter/material.dart';

class OverviewCard extends StatelessWidget {
  final String title;
  final double amount;
  final String currency;
  final IconData icon;
  final bool isIncome;

  const OverviewCard({
    super.key,
    required this.title,
    required this.amount,
    this.currency = 'VND',
    required this.icon,
    this.isIncome = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = theme.colorScheme.secondaryContainer;
    final iconBackgroundColor = isIncome
        ? theme.colorScheme.primary
        : theme.colorScheme.tertiary;
    final iconColor = theme.colorScheme.onPrimary;

    return Expanded(
      child: Card(
        elevation: 0,
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "+${CurrencyUtil.formatAmount(amount)}",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
