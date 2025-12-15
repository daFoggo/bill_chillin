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
  final String? shareLink;

  const GroupDetailLoaded({
    required this.group,
    required this.transactions,
    required this.debts,
    required this.totalExpense,
    this.shareLink,
  });

  @override
  @override
  List<Object?> get props => [
    group,
    transactions,
    debts,
    totalExpense,
    shareLink,
  ];

  GroupDetailLoaded copyWith({
    GroupEntity? group,
    List<TransactionEntity>? transactions,
    List<DebtEntity>? debts,
    double? totalExpense,
    String? shareLink,
    bool clearShareLink = false,
  }) {
    return GroupDetailLoaded(
      group: group ?? this.group,
      transactions: transactions ?? this.transactions,
      debts: debts ?? this.debts,
      totalExpense: totalExpense ?? this.totalExpense,
      shareLink: clearShareLink ? null : (shareLink ?? this.shareLink),
    );
  }
}

class GroupDetailError extends GroupDetailState {
  final String message;

  const GroupDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
