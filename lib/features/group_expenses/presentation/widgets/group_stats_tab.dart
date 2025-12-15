import 'package:bill_chillin/features/group_expenses/presentation/bloc/group_detail/group_detail_bloc.dart';
import 'package:bill_chillin/features/group_expenses/presentation/widgets/group_debts_list.dart';
import 'package:bill_chillin/features/group_expenses/presentation/widgets/group_stats_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupStatsTab extends StatelessWidget {
  final GroupDetailLoaded state;

  const GroupStatsTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // My Status
    final myDebts = state.debts
        .where((d) => d.fromUser == userId || d.toUser == userId)
        .toList();
    double iOwe = 0;
    double owedToMe = 0;

    for (var debt in myDebts) {
      if (debt.fromUser == userId) {
        iOwe += debt.amount;
      } else if (debt.toUser == userId) {
        owedToMe += debt.amount;
      }
    }
    final netBalance = owedToMe - iOwe;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GroupStatsCard(
            netBalance: netBalance,
            iOwe: iOwe,
            owedToMe: owedToMe,
          ),
          const SizedBox(height: 24),
          Text(
            "All Group Debts",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GroupDebtsList(state: state, userId: userId),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
