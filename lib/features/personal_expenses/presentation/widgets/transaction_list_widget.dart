import 'package:bill_chillin/features/personal_expenses/domain/entities/transaction_entity.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/widgets/transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionListWidget extends StatelessWidget {
  final List<TransactionEntity> transactions;
  final Function(TransactionEntity) onTap;
  final Function(TransactionEntity) onDismissed;
  final Function(TransactionEntity) onLongPress;

  const TransactionListWidget({
    super.key,
    required this.transactions,
    required this.onTap,
    required this.onDismissed,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text("No transactions this month"));
    }

    // Group transactions by week
    final Map<String, List<TransactionEntity>> groupedTransactions = {};
    for (var transaction in transactions) {
      // Calculate week number or just "Week start date"
      final date = transaction.date;
      // Let's use "Week of [Start Date]" logic
      // Find start of week (Monday)
      final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
      final weekKey =
          "Week ${DateFormat('dd/MM').format(startOfWeek)} - ${DateFormat('dd/MM').format(startOfWeek.add(const Duration(days: 6)))}";

      if (!groupedTransactions.containsKey(weekKey)) {
        groupedTransactions[weekKey] = [];
      }
      groupedTransactions[weekKey]!.add(transaction);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final weekKey = groupedTransactions.keys.elementAt(index);
        final weekTransactions = groupedTransactions[weekKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index != 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        weekKey,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 16),
            ...weekTransactions.map(
              (transaction) => TransactionItem(
                transaction: transaction,
                onTap: () => onTap(transaction),
                onLongPress: () => onLongPress(transaction),
                onDismissed: (_) => onDismissed(transaction),
              ),
            ),
          ],
        );
      },
    );
  }
}
