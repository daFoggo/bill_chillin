import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../personal_expenses/domain/entities/transaction_entity.dart';
import '../entities/group_entity.dart';

abstract class GroupRepository {
  Future<Either<Failure, void>> createGroup(GroupEntity group);
  Future<Either<Failure, List<GroupEntity>>> getGroups(String userId);
  Future<Either<Failure, GroupEntity>> getGroupDetails(String groupId);
  Future<Either<Failure, void>> joinGroup(String groupId, String userId);
  Future<Either<Failure, void>> leaveGroup(String groupId, String userId);

  Future<Either<Failure, void>> updateGroup(GroupEntity group);
  Future<Either<Failure, void>> deleteGroup(String groupId);

  // Group Transactions
  Future<Either<Failure, void>> addTransaction(
    String groupId,
    TransactionEntity transaction,
  );
  Future<Either<Failure, void>> updateTransaction(
    String groupId,
    TransactionEntity transaction,
  );
  Future<Either<Failure, void>> deleteTransaction(
    String groupId,
    String transactionId,
  );
  Future<Either<Failure, List<TransactionEntity>>> getGroupTransactions(
    String groupId,
  );

  // Group Member Management
  Future<Either<Failure, String>> generateInviteLink(String groupId);
  Future<Either<Failure, void>> joinGroupViaLink(
    String inviteCode,
    String userId,
  );
}
