import 'package:bill_chillin/core/util/currency_util.dart';
import 'package:bill_chillin/features/group_expenses/presentation/bloc/group_detail/group_detail_bloc.dart';
import 'package:flutter/material.dart';

class GroupMembersTab extends StatelessWidget {
  final GroupDetailLoaded state;

  const GroupMembersTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final members = state.group.members;
    final memberDetails = state.memberDetails;
    final debts = state.debts;

    if (members.isEmpty) {
      return const Center(child: Text("No members in this group"));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: theme.colorScheme.surfaceContainerLow,
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: members.length,
          separatorBuilder: (context, index) => Divider(
            indent: 16,
            endIndent: 16,
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          ),
          itemBuilder: (context, index) {
            final memberId = members[index];
            final user = memberDetails[memberId];

            // Calculate Net Balance
            double balance = 0;
            for (var debt in debts) {
              if (debt.toUser == memberId) {
                balance += debt.amount; // Owed to this user
              } else if (debt.fromUser == memberId) {
                balance -= debt.amount; // Use owes someone
              }
            }

            final isPositive = balance > 0;
            final isNegative = balance < 0;
            final isZero = balance == 0;

            Color balanceColor = theme.colorScheme.outline;
            if (isPositive) balanceColor = theme.colorScheme.primary;
            if (isNegative) balanceColor = theme.colorScheme.error;

            String balanceText = "Settled";
            if (!isZero) {
              balanceText = CurrencyUtil.format(balance.abs());
              if (isPositive) balanceText = "+$balanceText";
              if (isNegative) balanceText = "-$balanceText";
            }

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                backgroundImage:
                    user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
                    ? Text(
                        (user?.name != null && user!.name!.isNotEmpty)
                            ? user.name![0].toUpperCase()
                            : "?",
                        style: TextStyle(
                          color: theme
                              .colorScheme
                              .onSurfaceVariant, // consistent with debt list
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              title: Text(
                user?.name ?? "Unknown User",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                user?.email ?? "No email", // Or maybe join date?
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    balanceText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: balanceColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isZero)
                    Text(
                      isPositive ? "Owed" : "Owes",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: balanceColor,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
