import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/group_repository.dart';

class DeleteGroupTransactionUseCase
    implements UseCase<void, DeleteGroupTransactionParams> {
  final GroupRepository repository;

  DeleteGroupTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteGroupTransactionParams params) {
    return repository.deleteTransaction(params.groupId, params.transactionId);
  }
}

class DeleteGroupTransactionParams extends Equatable {
  final String groupId;
  final String transactionId;

  const DeleteGroupTransactionParams({
    required this.groupId,
    required this.transactionId,
  });

  @override
  List<Object?> get props => [groupId, transactionId];
}
