part of 'group_detail_bloc.dart';

abstract class GroupDetailState extends Equatable {
  const GroupDetailState();

  @override
  List<Object?> get props => [];
}

class GroupDetailInitial extends GroupDetailState {}

class GroupDetailLoading extends GroupDetailState {}

class GroupDetailLoaded extends GroupDetailState {
  final GroupEntity group;
  final List<TransactionEntity> transactions;
  final List<DebtEntity> debts;
  final double totalExpense;

  const GroupDetailLoaded({
    required this.group,
    required this.transactions,
    required this.debts,
    required this.totalExpense,
  });

  @override
  List<Object?> get props => [group, transactions, debts, totalExpense];
}

class GroupDetailError extends GroupDetailState {
  final String message;

  const GroupDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
