import 'package:bill_chillin/core/error/failures.dart';
import 'package:bill_chillin/features/auth/domain/entities/user_entity.dart';
import 'package:bill_chillin/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class GetGroupMemberDetailsUseCase {
  final AuthRepository repository;

  GetGroupMemberDetailsUseCase(this.repository);

  Future<Either<Failure, List<UserEntity>>> call(List<String> userIds) {
    return repository.getUsersByIds(userIds);
  }
}
