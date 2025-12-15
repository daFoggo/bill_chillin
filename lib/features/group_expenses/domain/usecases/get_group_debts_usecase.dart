import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/group_repository.dart';

class GetGroupDebtsUseCase
    implements UseCase<List<DebtEntity>, GetGroupDebtsParams> {
  final GroupRepository repository;

  GetGroupDebtsUseCase(this.repository);

  @override
  Future<Either<Failure, List<DebtEntity>>> call(
    GetGroupDebtsParams params,
  ) async {
    // 1. Fetch transactions
    final transactionsResult = await repository.getGroupTransactions(
      params.groupId,
    );

    return transactionsResult.fold((failure) => Left(failure), (transactions) {
      // 2. Calculate Net Balances
      // Map<UserId, Balance>
      final Map<String, double> balances = {};

      for (var tx in transactions) {
        final payerId = tx.payerId;
        final amount = tx.amount;
        final splitDetails = tx.splitDetails;

        if (payerId == null || splitDetails == null) continue;

        // Payer paid 'amount', so they are OWED this amount (positive balance)
        // However, if they are also in the split, they owe a portion back.
        // Usually splitDetails contains { 'userId': amountOwed }

        // Let's assume splitDetails is how much each person OWES for this transaction.
        // The sum of splitDetails values should equal data.amount.
        // (Or slightly different if rounding, but we assume equal).

        // Payer gets +amount (temporarily, simpler to think: Payer paid full amount)
        balances[payerId] = (balances[payerId] ?? 0) + amount;

        // Each participant owes their share (negative balance)
        splitDetails.forEach((uid, owedAmount) {
          balances[uid] = (balances[uid] ?? 0) - owedAmount;
        });
      }

      // 3. Simplify Debts
      // Algorithm:
      // Separate into debtors (negative balance) and creditors (positive balance).
      // Match them greedily or using a specific algorithm.
      // For simplicity: Simple greedy matching.
      // Take largest debtor and largest creditor, transfer min(abs(debt), credit).

      final List<DebtEntity> debts = [];

      // Remove users with ~0 balance
      final debtors = balances.keys
          .where((k) => (balances[k] ?? 0) < -0.01)
          .toList();
      final creditors = balances.keys
          .where((k) => (balances[k] ?? 0) > 0.01)
          .toList();

      // Sort by magnitude (optional but good for minimizing transactions)
      debtors.sort(
        (a, b) => balances[a]!.compareTo(balances[b]!),
      ); // Ascending (largest debt first)
      creditors.sort(
        (a, b) => balances[b]!.compareTo(balances[a]!),
      ); // Descending (largest credit first)

      int debtorIdx = 0;
      int creditorIdx = 0;

      while (debtorIdx < debtors.length && creditorIdx < creditors.length) {
        final debtor = debtors[debtorIdx];
        final creditor = creditors[creditorIdx];

        final debtAmount = -(balances[debtor]!);
        final creditAmount = balances[creditor]!;

        final amount = debtAmount < creditAmount ? debtAmount : creditAmount;

        debts.add(DebtEntity(from: debtor, to: creditor, amount: amount));

        balances[debtor] = balances[debtor]! + amount;
        balances[creditor] = balances[creditor]! - amount;

        if (balances[debtor]!.abs() < 0.01) debtorIdx++;
        if (balances[creditor]!.abs() < 0.01) creditorIdx++;
      }

      return Right(debts);
    });
  }
}

class GetGroupDebtsParams extends Equatable {
  final String groupId;

  const GetGroupDebtsParams({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

class DebtEntity extends Equatable {
  final String from;
  final String to;
  final double amount;

  const DebtEntity({
    required this.from,
    required this.to,
    required this.amount,
  });

  @override
  List<Object?> get props => [from, to, amount];
}
