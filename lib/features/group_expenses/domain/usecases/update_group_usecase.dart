import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';

class UpdateGroupUseCase implements UseCase<void, GroupEntity> {
  final GroupRepository repository;

  UpdateGroupUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(GroupEntity params) {
    return repository.updateGroup(params);
  }
}
