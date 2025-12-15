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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (transaction.groupName != null &&
                    transaction.groupName!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.groups_3,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        transaction.groupName!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: transaction.type == 'settlement'
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: transaction.type == 'settlement'
                            ? Icon(
                                Icons.handshake,
                                color: theme.colorScheme.onPrimaryContainer,
                                size: 24,
                              )
                            : Text(
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
                              final isMidnight =
                                  date.hour == 0 && date.minute == 0;

                              String dateString = DateFormat(
                                'dd MMM',
                              ).format(date);
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
                      transaction.type == 'settlement'
                          ? CurrencyUtil.format(transaction.amount)
                          : '${isIncome ? '+' : '-'}${CurrencyUtil.format(transaction.amount)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: transaction.type == 'settlement'
                            ? theme.colorScheme.primary
                            : amountColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
