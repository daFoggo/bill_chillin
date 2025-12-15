import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/group_repository.dart';

class JoinGroupUseCase implements UseCase<void, JoinGroupParams> {
  final GroupRepository repository;

  JoinGroupUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(JoinGroupParams params) async {
    return await repository.joinGroup(params.groupId, params.userId);
  }
}

class JoinGroupParams extends Equatable {
  final String groupId;
  final String userId;

  const JoinGroupParams({required this.groupId, required this.userId});

  @override
  List<Object?> get props => [groupId, userId];
}
