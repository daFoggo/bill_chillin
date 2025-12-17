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
    final transactionsResult = await repository.getGroupTransactions(
      params.groupId,
    );

    return transactionsResult.fold((failure) => Left(failure), (transactions) {
      final Map<String, double> balances = {};

      for (var tx in transactions) {
        final payerId = tx.payerId;
        final amount = tx.amount;
        final splitDetails = tx.splitDetails;

        if (payerId == null || splitDetails == null) continue;
        balances[payerId] = (balances[payerId] ?? 0) + amount;
        splitDetails.forEach((uid, owedAmount) {
          balances[uid] = (balances[uid] ?? 0) - owedAmount;
        });
      }

      final List<DebtEntity> debts = [];

      final debtors = balances.keys
          .where((k) => (balances[k] ?? 0) < -0.01)
          .toList();
      final creditors = balances.keys
          .where((k) => (balances[k] ?? 0) > 0.01)
          .toList();

      debtors.sort((a, b) => balances[a]!.compareTo(balances[b]!));
      creditors.sort((a, b) => balances[b]!.compareTo(balances[a]!));

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
