import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/group_entity.dart';

abstract class GroupRepository {
  Future<Either<Failure, void>> createGroup(GroupEntity group);
  Future<Either<Failure, List<GroupEntity>>> getGroups(String userId);
  Future<Either<Failure, GroupEntity>> getGroupDetails(String groupId);
  Future<Either<Failure, void>> joinGroup(String groupId, String userId);
  Future<Either<Failure, void>> leaveGroup(String groupId, String userId);
}
