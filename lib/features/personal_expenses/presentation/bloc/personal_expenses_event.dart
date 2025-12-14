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

// Bạn có thể thêm Delete/Update Event sau
