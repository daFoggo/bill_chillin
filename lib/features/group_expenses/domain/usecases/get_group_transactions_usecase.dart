import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../personal_expenses/domain/entities/transaction_entity.dart';
import '../repositories/group_repository.dart';

class GetGroupTransactionsUseCase
    implements UseCase<List<TransactionEntity>, GetGroupTransactionsParams> {
  final GroupRepository repository;

  GetGroupTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(
    GetGroupTransactionsParams params,
  ) async {
    return await repository.getGroupTransactions(params.groupId);
  }
}

class GetGroupTransactionsParams extends Equatable {
  final String groupId;

  const GetGroupTransactionsParams({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}
