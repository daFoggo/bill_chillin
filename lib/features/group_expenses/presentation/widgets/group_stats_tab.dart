import 'package:bill_chillin/features/group_expenses/presentation/bloc/group_detail/group_detail_bloc.dart';
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
          // My Summary Card
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "My Net Balance",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${netBalance >= 0 ? '+' : ''}${netBalance.toStringAsFixed(0)}",
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: netBalance >= 0
                          ? Colors.green
                          : theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text("I Owe"),
                          Text(
                            iOwe.toStringAsFixed(0),
                            style: TextStyle(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Owed to Me"),
                          Text(
                            owedToMe.toStringAsFixed(0),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "All Group Debts",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (state.debts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("All squared up! No debts."),
              ),
            )
          else
            ...state.debts.map((debt) {
              final fromUser = state.memberDetails[debt.fromUser];
              final toUser = state.memberDetails[debt.toUser];
              final fromName = debt.fromUser == userId
                  ? 'You'
                  : (fromUser?.name ?? 'Unknown');
              final toName = debt.toUser == userId
                  ? 'You'
                  : (toUser?.name ?? 'Unknown');

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: fromUser?.avatarUrl != null
                      ? NetworkImage(fromUser!.avatarUrl!)
                      : null,
                  child: fromUser?.avatarUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text("$fromName owes $toName"),
                trailing: Text(
                  debt.amount.toStringAsFixed(0),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }),
        ],
      ),
    );
  }
}
