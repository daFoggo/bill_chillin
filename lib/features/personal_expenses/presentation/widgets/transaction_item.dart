import 'package:bill_chillin/core/util/currency_util.dart';
import 'package:bill_chillin/features/personal_expenses/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(DismissDirection)? onDismissed;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onLongPress,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = transaction.type == 'income';
    final amountColor = isIncome
        ? theme.colorScheme.primary
        : theme.colorScheme.error;

    return Dismissible(
      key: Key(transaction.id),
      direction: onDismissed != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      onDismissed: onDismissed,
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerLow,
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      transaction.categoryIcon.isNotEmpty
                          ? transaction.categoryIcon
                          : (isIncome ? '+' : '-'),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (transaction.note != null &&
                                transaction.note!.isNotEmpty)
                            ? transaction.note!
                            : transaction.categoryName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (transaction.note != null &&
                          transaction.note!.isNotEmpty)
                        Text(
                          transaction.categoryName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      Builder(
                        builder: (context) {
                          final date = transaction.date;
                          final isMidnight = date.hour == 0 && date.minute == 0;

                          String dateString = DateFormat('dd MMM').format(date);
                          if (!isMidnight) {
                            dateString +=
                                ", ${DateFormat('HH:mm').format(date)}";
                          }

                          return Text(
                            dateString,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                Text(
                  '${isIncome ? '+' : '-'}${CurrencyUtil.format(transaction.amount)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
