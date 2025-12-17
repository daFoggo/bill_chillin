import 'dart:math';

import '../../../personal_expenses/domain/entities/transaction_entity.dart';
import '../entities/debt_entity.dart';

class CalculateGroupDebtsUseCase {
  List<DebtEntity> call(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) return [];

    Map<String, double> balances = {};

    for (var tx in transactions) {
      if (tx.payerId == null || tx.amount <= 0) continue;
      balances[tx.payerId!] = (balances[tx.payerId!] ?? 0) + tx.amount;

      if (tx.splitDetails != null && tx.splitDetails!.isNotEmpty) {
        tx.splitDetails!.forEach((userId, share) {
          balances[userId] = (balances[userId] ?? 0) - share;
        });
      } else if (tx.participants != null && tx.participants!.isNotEmpty) {
        double share = tx.amount / tx.participants!.length;
        for (var userId in tx.participants!) {
          balances[userId] = (balances[userId] ?? 0) - share;
        }
      }
    }

    List<MapEntry<String, double>> debtors = [];
    List<MapEntry<String, double>> creditors = [];

    balances.forEach((userId, amount) {
      if (amount.abs() > 0.01) {
        if (amount > 0) {
          creditors.add(MapEntry(userId, amount));
        } else {
          debtors.add(MapEntry(userId, amount));
        }
      }
    });
    debtors.sort((a, b) => a.value.compareTo(b.value));
    creditors.sort((a, b) => b.value.compareTo(a.value));

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

      if (debtAmount > creditAmount) {
        debtors[debtorIndex] = MapEntry(
          debtor.key,
          debtor.value + settledAmount,
        );
        creditorIndex++;
      } else if (debtAmount < creditAmount) {
        creditors[creditorIndex] = MapEntry(
          creditor.key,
          creditor.value - settledAmount,
        );
        debtorIndex++;
      } else {
        debtorIndex++;
        creditorIndex++;
      }
    }

    return debts;
  }
}
