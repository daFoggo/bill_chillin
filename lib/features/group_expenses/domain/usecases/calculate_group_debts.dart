import 'dart:math';

import '../../../personal_expenses/domain/entities/transaction_entity.dart';
import '../entities/debt_entity.dart';

class CalculateGroupDebtsUseCase {
  List<DebtEntity> call(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) return [];

    // 1. Calculate Net Balance for each user
    Map<String, double> balances = {};

    for (var tx in transactions) {
      if (tx.payerId == null || tx.amount <= 0) continue;

      // Payer paid the full amount, so they are "owed" this amount initially
      // But we will subtract their own share later if they are in participants
      // Easier way: Net Effect = Paid - Share

      // Payer adds +amount to their balance (they are creditor relative to the pot)
      balances[tx.payerId!] = (balances[tx.payerId!] ?? 0) + tx.amount;

      // Each participant owes their share
      if (tx.splitDetails != null && tx.splitDetails!.isNotEmpty) {
        tx.splitDetails!.forEach((userId, share) {
          balances[userId] = (balances[userId] ?? 0) - share;
        });
      } else if (tx.participants != null && tx.participants!.isNotEmpty) {
        // Equal split
        double share = tx.amount / tx.participants!.length;
        for (var userId in tx.participants!) {
          balances[userId] = (balances[userId] ?? 0) - share;
        }
      }
    }

    // 2. Separate into Debtors and Creditors
    List<MapEntry<String, double>> debtors = [];
    List<MapEntry<String, double>> creditors = [];

    // Filter out negligible balances
    balances.forEach((userId, amount) {
      // Precision issue check
      if (amount.abs() > 0.01) {
        if (amount > 0) {
          creditors.add(MapEntry(userId, amount));
        } else {
          debtors.add(MapEntry(userId, amount));
        }
      }
    });

    // 3. Simplify Debts (Greedy Algorithm)
    // Sort to optimize fewer transactions (optional, but matching largest with largest usually helps)
    debtors.sort(
      (a, b) => a.value.compareTo(b.value),
    ); // ascending (most negative first)
    creditors.sort(
      (a, b) => b.value.compareTo(a.value),
    ); // descending (most positive first)

    List<DebtEntity> debts = [];
    int debtorIndex = 0;
    int creditorIndex = 0;

    while (debtorIndex < debtors.length && creditorIndex < creditors.length) {
      var debtor = debtors[debtorIndex];
      var creditor = creditors[creditorIndex];

      double debtAmount = debtor.value.abs();
      double creditAmount = creditor.value;
      double settledAmount = min(debtAmount, creditAmount);

      debts.add(
        DebtEntity(
          fromUser: debtor.key,
          toUser: creditor.key,
          amount: settledAmount,
        ),
      );

      // Update remaining amounts
      if (debtAmount > creditAmount) {
        // Debtor still owes
        debtors[debtorIndex] = MapEntry(
          debtor.key,
          debtor.value + settledAmount,
        ); // making it less negative
        creditorIndex++;
      } else if (debtAmount < creditAmount) {
        // Creditor still owed
        creditors[creditorIndex] = MapEntry(
          creditor.key,
          creditor.value - settledAmount,
        );
        debtorIndex++;
      } else {
        // Both settled
        debtorIndex++;
        creditorIndex++;
      }
    }

    return debts;
  }
}
