import 'package:bill_chillin/features/personal_expenses/domain/entities/transaction_entity.dart';
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
  const PersonalExpensesLoaded(this.transactions);
  @override
  List<Object> get props => [transactions];
}

class PersonalExpensesError extends PersonalExpensesState {
  final String message;
  const PersonalExpensesError(this.message);
  @override
  List<Object> get props => [message];
}

class PersonalExpensesOperationSuccess extends PersonalExpensesState {
  final String message; // Ví dụ: "Thêm thành công"
  const PersonalExpensesOperationSuccess(this.message);
}
