import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/personal_expenses_repository.dart';
import '../datasources/personal_expenses_remote_data_source.dart';

import 'package:bill_chillin/features/group_expenses/data/datasources/group_remote_data_source.dart';

class PersonalExpensesRepositoryImpl implements PersonalExpensesRepository {
  final PersonalExpensesRemoteDataSource remoteDataSource;
  final GroupRemoteDataSource groupRemoteDataSource;

  PersonalExpensesRepositoryImpl({
    required this.remoteDataSource,
    required this.groupRemoteDataSource,
  });

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
      // 1. Fetch Personal Transactions
      final personalTransactions = await remoteDataSource.getTransactions(
        userId,
      );

      // 2. Fetch Group Transactions
      List<TransactionEntity> groupTransactionsList = [];
      try {
        final groups = await groupRemoteDataSource.getGroups(userId);
        for (var group in groups) {
          final gTransactions = await groupRemoteDataSource
              .getGroupTransactions(group.id);

          // Filter and Transform
          final relevantTransactions = gTransactions
              .where((tx) {
                // Exclude settlements
                if (tx.type == 'settlement') return false;

                // Must be involved
                final isPayer = tx.payerId == userId;
                final isParticipant =
                    tx.participants?.contains(userId) ?? false;

                return isPayer || isParticipant;
              })
              .map((tx) {
                // Calculate effective amount (My Share)
                // If I am a participant, my share is explicitly defined in splitDetails
                // If I am ONLY payer (not participant), then I paid for others, so my expense is 0.
                // If I am both, I paid effectively for myself + others, but my EXPENSE is just my share.

                final myShare = tx.splitDetails?[userId] ?? 0.0;

                // Create a copy with modified amount to reflect personal expense
                // We use the same ID, but maybe we should ensure uniqueness?
                // ID conflict is unlikely unless we use duplicate IDs across collections.
                // Firestore IDs are usually unique.

                // We return a TransactionEntity (Model extends Entity)
                return TransactionEntity(
                  id: tx.id,
                  userId: tx.userId,
                  amount: myShare, // Override amount with my share
                  currency: tx.currency,
                  type: tx.type,
                  date: tx.date,
                  categoryId: tx.categoryId,
                  categoryName: tx.categoryName,
                  categoryIcon: tx.categoryIcon,
                  note: tx.note,
                  createdAt: tx.createdAt,
                  updatedAt: tx.updatedAt,
                  status: tx.status,
                  groupId: tx.groupId,
                  groupName: group.name,
                  payerId: tx.payerId,
                  participants: tx.participants,
                  splitDetails: tx.splitDetails,
                  imageUrl: tx.imageUrl,
                  searchKeywords: tx.searchKeywords,
                );
              })
              .where(
                (tx) => tx.amount > 0,
              ); // Only include if there is a non-zero expense share

          groupTransactionsList.addAll(relevantTransactions);
        }
      } catch (e) {
        rethrow;
      }

      // 3. Merge and Sort
      final allTransactions = [
        ...personalTransactions,
        ...groupTransactionsList,
      ];
      allTransactions.sort((a, b) => b.date.compareTo(a.date));

      return Right(allTransactions);
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
