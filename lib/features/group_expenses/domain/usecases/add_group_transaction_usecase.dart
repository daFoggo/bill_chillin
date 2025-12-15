import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../personal_expenses/domain/entities/transaction_entity.dart';
import '../repositories/group_repository.dart';

class AddGroupTransactionUseCase
    implements UseCase<void, AddGroupTransactionParams> {
  final GroupRepository repository;

  AddGroupTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddGroupTransactionParams params) async {
    return await repository.addTransaction(params.groupId, params.transaction);
  }
}

class AddGroupTransactionParams extends Equatable {
  final String groupId;
  final TransactionEntity transaction;

  const AddGroupTransactionParams({
    required this.groupId,
    required this.transaction,
  });

  @override
  List<Object?> get props => [groupId, transaction];
}
