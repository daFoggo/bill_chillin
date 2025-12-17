import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/repositories/group_repository.dart';
import '../../../personal_expenses/data/models/transaction_model.dart';
import '../../../personal_expenses/domain/entities/transaction_entity.dart';
import '../datasources/group_remote_data_source.dart';
import '../models/group_model.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource remoteDataSource;

  GroupRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> createGroup(GroupEntity group) async {
    try {
      final groupModel = GroupModel(
        id: group.id,
        name: group.name,
        members: group.members,
        currency: group.currency,
        createdBy: group.createdBy,
        createdAt: group.createdAt,
        imageUrl: group.imageUrl,
      );
      await remoteDataSource.createGroup(groupModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GroupEntity>>> getGroups(String userId) async {
    try {
      final result = await remoteDataSource.getGroups(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> getGroupDetails(String groupId) async {
    try {
      final result = await remoteDataSource.getGroupDetails(groupId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> joinGroup(String groupId, String userId) async {
    try {
      await remoteDataSource.joinGroup(groupId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveGroup(
    String groupId,
    String userId,
  ) async {
    try {
      await remoteDataSource.leaveGroup(groupId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateGroup(GroupEntity group) async {
    try {
      final groupModel = GroupModel(
        id: group.id,
        name: group.name,
        members: group.members,
        currency: group.currency,
        createdBy: group.createdBy,
        createdAt: group.createdAt,
        imageUrl: group.imageUrl,
      );
      await remoteDataSource.updateGroup(groupModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGroup(String groupId) async {
    try {
      await remoteDataSource.deleteGroup(groupId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> generateInviteLink(String groupId) async {
    try {
      final link = await remoteDataSource.generateInviteLink(groupId);
      return Right(link);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> joinGroupViaLink(
    String inviteCode,
    String userId,
  ) async {
    try {
      String groupId = inviteCode;
      final prefixes = [
        'https://billchillin.web.app/app/join/',
        'http://billchillin.web.app/app/join/',
        'https://billchillin.firebaseapp.com/app/join/',
        'http://billchillin.firebaseapp.com/app/join/',
        'billchillin://app/join/',
        'billchillin://join/',
      ];

      for (final prefix in prefixes) {
        if (inviteCode.startsWith(prefix)) {
          groupId = inviteCode.split(prefix).last;
          break;
        }
      }

      await remoteDataSource.joinGroup(groupId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(
    String groupId,
    TransactionEntity transaction,
  ) async {
    try {
      final transactionModel = TransactionModel(
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
      await remoteDataSource.addTransaction(groupId, transactionModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTransaction(
    String groupId,
    TransactionEntity transaction,
  ) async {
    try {
      final transactionModel = TransactionModel(
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
      await remoteDataSource.updateTransaction(groupId, transactionModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(
    String groupId,
    String transactionId,
  ) async {
    try {
      await remoteDataSource.deleteTransaction(groupId, transactionId);
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
}
