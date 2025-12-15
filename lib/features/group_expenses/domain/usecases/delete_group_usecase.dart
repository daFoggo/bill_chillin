import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/group_repository.dart';

class DeleteGroupUseCase implements UseCase<void, String> {
  final GroupRepository repository;

  DeleteGroupUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.deleteGroup(params);
  }
}
