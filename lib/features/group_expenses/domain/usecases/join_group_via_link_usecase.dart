import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/group_repository.dart';

class JoinGroupViaLinkUseCase implements UseCase<void, JoinGroupViaLinkParams> {
  final GroupRepository repository;

  JoinGroupViaLinkUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(JoinGroupViaLinkParams params) async {
    return await repository.joinGroupViaLink(params.inviteCode, params.userId);
  }
}

class JoinGroupViaLinkParams extends Equatable {
  final String inviteCode;
  final String userId;

  const JoinGroupViaLinkParams({
    required this.inviteCode,
    required this.userId,
  });

  @override
  List<Object?> get props => [inviteCode, userId];
}
