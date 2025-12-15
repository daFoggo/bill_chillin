import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';

class CreateGroupUseCase implements UseCase<void, CreateGroupParams> {
  final GroupRepository repository;

  CreateGroupUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateGroupParams params) async {
    return await repository.createGroup(params.group);
  }
}

class CreateGroupParams extends Equatable {
  final GroupEntity group;

  const CreateGroupParams({required this.group});

  @override
  List<Object?> get props => [group];
}
