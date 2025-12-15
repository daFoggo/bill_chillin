import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../personal_expenses/data/models/transaction_model.dart';
import '../../../personal_expenses/domain/entities/transaction_entity.dart';
import '../../domain/repositories/group_expense_repository.dart';
import '../datasources/group_expense_remote_data_source.dart';

class GroupExpenseRepositoryImpl implements GroupExpenseRepository {
  final GroupExpenseRemoteDataSource remoteDataSource;

  GroupExpenseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> addTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = TransactionModel(
        id: transaction.id,
        userId: transaction.userId,
        amount: transaction.amount,
        currency: transaction.currency,
        type: transaction.type,
        date: transaction.date,
        categoryId: transaction.categoryId,
        categoryName: transaction.categoryName,
        categoryIcon: transaction.categoryIcon,
        note: transaction.note,
        searchKeywords: transaction.searchKeywords,
        status: transaction.status,
        imageUrl: transaction.imageUrl,
        createdAt: transaction.createdAt,
        updatedAt: transaction.updatedAt,
        groupId: transaction.groupId,
        payerId: transaction.payerId,
        participants: transaction.participants,
        splitDetails: transaction.splitDetails,
      );
      await remoteDataSource.addTransaction(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getGroupTransactions(
    String groupId,
  ) async {
    try {
      final result = await remoteDataSource.getGroupTransactions(groupId);
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
      final model = TransactionModel(
        id: transaction.id,
        userId: transaction.userId,
        amount: transaction.amount,
        currency: transaction.currency,
        type: transaction.type,
        date: transaction.date,
        categoryId: transaction.categoryId,
        categoryName: transaction.categoryName,
        categoryIcon: transaction.categoryIcon,
        note: transaction.note,
        searchKeywords: transaction.searchKeywords,
        status: transaction.status,
        imageUrl: transaction.imageUrl,
        createdAt: transaction.createdAt,
        updatedAt: transaction.updatedAt,
        groupId: transaction.groupId,
        payerId: transaction.payerId,
        participants: transaction.participants,
        splitDetails: transaction.splitDetails,
      );
      await remoteDataSource.updateTransaction(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(
    String transactionId,
    String groupId,
  ) async {
    try {
      await remoteDataSource.deleteTransaction(transactionId, groupId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
