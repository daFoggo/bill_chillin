import 'package:bill_chillin/core/util/currency_util.dart';
import 'package:bill_chillin/features/auth/domain/entities/user_entity.dart';
import 'package:bill_chillin/features/group_expenses/presentation/bloc/group_detail/group_detail_bloc.dart';
import 'package:bill_chillin/features/personal_expenses/domain/entities/transaction_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupDebtsList extends StatelessWidget {
  final GroupDetailLoaded state;
  final String? userId;

  const GroupDebtsList({super.key, required this.state, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state.debts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                "All squared up! No debts.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerLow,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.debts.length,
        separatorBuilder: (context, index) => Divider(
          indent: 16,
          endIndent: 16,
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        itemBuilder: (context, index) {
          final debt = state.debts[index];
          final fromUser = state.memberDetails[debt.fromUser];
          final toUser = state.memberDetails[debt.toUser];
          final fromName = debt.fromUser == userId
              ? 'You'
              : (fromUser?.name ?? 'Unknown');
          final toName = debt.toUser == userId
              ? 'You'
              : (toUser?.name ?? 'Unknown');
          final isMyDebt = debt.fromUser == userId;

          return ListTile(
            onTap: isMyDebt
                ? () => _showSettleDialog(context, toUser, debt.amount, state)
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              backgroundImage: fromUser?.avatarUrl != null
                  ? NetworkImage(fromUser!.avatarUrl!)
                  : null,
              child: fromUser?.avatarUrl == null
                  ? Icon(
                      Icons.person,
                      color: theme.colorScheme.onSurfaceVariant,
                    )
                  : null,
            ),
            title: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                children: [
                  TextSpan(
                    text: fromName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: " owes ",
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  TextSpan(
                    text: toName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  CurrencyUtil.format(debt.amount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (isMyDebt) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSettleDialog(
    BuildContext context,
    UserEntity? toUser,
    double amount,
    GroupDetailLoaded state,
  ) {
    if (toUser == null) return;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Mark as Paid?"),
        content: RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            children: [
              const TextSpan(text: "Confirm you paid "),
              TextSpan(
                text: CurrencyUtil.format(amount),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: " to "),
              TextSpan(
                text: toUser.name ?? "Unknown",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text: "?\n\nThis will add a settlement transaction.",
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                // Create settlement transaction
                final settlementTx = TransactionEntity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  userId: user.uid,
                  amount: amount,
                  type: 'settlement',
                  date: DateTime.now(),
                  categoryId: 'settlement',
                  categoryName: 'Settlement',
                  categoryIcon: '💸',
                  status: 'confirmed',
                  createdAt: DateTime.now(),
                  groupId: state.group.id,
                  payerId: user.uid,
                  participants: [toUser.id],
                  splitDetails: {toUser.id: amount},
                );

                context.read<GroupDetailBloc>().add(
                  AddGroupTransactionEvent(transaction: settlementTx),
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}
