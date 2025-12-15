import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../personal_expenses/domain/entities/transaction_entity.dart';
import '../repositories/group_repository.dart';

class UpdateGroupTransactionUseCase
    implements UseCase<void, UpdateGroupTransactionParams> {
  final GroupRepository repository;

  UpdateGroupTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateGroupTransactionParams params) {
    return repository.updateTransaction(params.groupId, params.transaction);
  }
}

class UpdateGroupTransactionParams extends Equatable {
  final String groupId;
  final TransactionEntity transaction;

  const UpdateGroupTransactionParams({
    required this.groupId,
    required this.transaction,
  });

  @override
  List<Object?> get props => [groupId, transaction];
}
