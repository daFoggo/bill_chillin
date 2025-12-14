import 'package:bill_chillin/features/personal_expenses/domain/entities/transaction_entity.dart';
import 'package:equatable/equatable.dart';

abstract class PersonalExpensesEvent extends Equatable {
  const PersonalExpensesEvent();

  @override
  List<Object> get props => [];
}

class LoadPersonalExpensesEvent extends PersonalExpensesEvent {
  final String userId;
  const LoadPersonalExpensesEvent(this.userId);
  @override
  List<Object> get props => [userId];
}

class AddPersonalExpenseEvent extends PersonalExpensesEvent {
  final TransactionEntity transaction;
  const AddPersonalExpenseEvent(this.transaction);
  @override
  List<Object> get props => [transaction];
}

enum SortCriteria { dateDesc, dateAsc, category }

class ChangeMonthEvent extends PersonalExpensesEvent {
  final DateTime month;
  const ChangeMonthEvent(this.month);
  @override
  List<Object> get props => [month];
}

class ChangeSortCriteriaEvent extends PersonalExpensesEvent {
  final SortCriteria criteria;
  const ChangeSortCriteriaEvent(this.criteria);
  @override
  List<Object> get props => [criteria];
}

class UpdateTransactionEvent extends PersonalExpensesEvent {
  final TransactionEntity transaction;
  const UpdateTransactionEvent(this.transaction);
  @override
  List<Object> get props => [transaction];
}

class DeleteTransactionEvent extends PersonalExpensesEvent {
  final String transactionId;
  final String userId;
  const DeleteTransactionEvent(this.transactionId, this.userId);
  @override
  List<Object> get props => [transactionId, userId];
}

class SearchTransactionEvent extends PersonalExpensesEvent {
  final String query;
  const SearchTransactionEvent(this.query);
  @override
  List<Object> get props => [query];
}

class DeleteMultipleTransactionsEvent extends PersonalExpensesEvent {
  final List<String> transactionIds;
  final String userId;
  const DeleteMultipleTransactionsEvent(this.transactionIds, this.userId);
  @override
  List<Object> get props => [transactionIds, userId];
}
