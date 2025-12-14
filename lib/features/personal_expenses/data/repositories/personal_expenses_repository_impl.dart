import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/personal_expenses_repository.dart';
import '../datasources/personal_expenses_remote_data_source.dart';

class PersonalExpensesRepositoryImpl implements PersonalExpensesRepository {
  final PersonalExpensesRemoteDataSource remoteDataSource;

  PersonalExpensesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> addTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      await remoteDataSource.addTransaction(transaction);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    required String userId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final result = await remoteDataSource.getTransactions(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      await remoteDataSource.updateTransaction(transaction);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(
    String transactionId,
    String userId,
  ) async {
    try {
      await remoteDataSource.deleteTransaction(transactionId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
