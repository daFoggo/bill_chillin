import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../personal_expenses/domain/entities/transaction_entity.dart';

abstract class GroupExpenseRepository {
  Future<Either<Failure, void>> addTransaction(TransactionEntity transaction);
  Future<Either<Failure, void>> updateTransaction(
    TransactionEntity transaction,
  );
  Future<Either<Failure, void>> deleteTransaction(
    String transactionId,
    String groupId,
  );
  Future<Either<Failure, List<TransactionEntity>>> getGroupTransactions(
    String groupId,
  );
}
