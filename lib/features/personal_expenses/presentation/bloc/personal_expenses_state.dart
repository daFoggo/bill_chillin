import 'package:bill_chillin/features/personal_expenses/domain/entities/transaction_entity.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/personal_expenses_event.dart';
import 'package:equatable/equatable.dart';

abstract class PersonalExpensesState extends Equatable {
  const PersonalExpensesState();
  @override
  List<Object> get props => [];
}

class PersonalExpensesInitial extends PersonalExpensesState {}

class PersonalExpensesLoading extends PersonalExpensesState {}

class PersonalExpensesLoaded extends PersonalExpensesState {
  final List<TransactionEntity> transactions;
  final DateTime currentMonth;
  final SortCriteria sortCriteria;
  final String searchQuery;

  const PersonalExpensesLoaded(
    this.transactions, {
    required this.currentMonth,
    this.sortCriteria = SortCriteria.dateDesc,
    this.searchQuery = '',
  });

  @override
  List<Object> get props => [
    transactions,
    currentMonth,
    sortCriteria,
    searchQuery,
  ];
}

class PersonalExpensesError extends PersonalExpensesState {
  final String message;
  const PersonalExpensesError(this.message);
  @override
  List<Object> get props => [message];
}

class PersonalExpensesOperationSuccess extends PersonalExpensesState {
  final String message;
  const PersonalExpensesOperationSuccess(this.message);
}
