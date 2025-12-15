import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/group_repository.dart';

class GenerateInviteLinkUseCase implements UseCase<String, String> {
  final GroupRepository repository;

  GenerateInviteLinkUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(String groupId) async {
    return await repository.generateInviteLink(groupId);
  }
}
