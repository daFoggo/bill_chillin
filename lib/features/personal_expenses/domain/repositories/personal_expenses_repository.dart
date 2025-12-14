import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/transaction_entity.dart';

abstract class PersonalExpensesRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    required String userId,
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<Either<Failure, void>> addTransaction(TransactionEntity transaction);

  Future<Either<Failure, void>> updateTransaction(
    TransactionEntity transaction,
  );

  Future<Either<Failure, void>> deleteTransaction(
    String transactionId,
    String userId,
  );
}
