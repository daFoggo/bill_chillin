import 'package:bill_chillin/features/personal_expenses/presentation/bloc/personal_expenses_event.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/personal_expenses_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/personal_expenses_repository.dart';

class PersonalExpensesBloc
    extends Bloc<PersonalExpensesEvent, PersonalExpensesState> {
  final PersonalExpensesRepository repository;

  PersonalExpensesBloc({required this.repository})
    : super(PersonalExpensesInitial()) {
    on<LoadPersonalExpensesEvent>((event, emit) async {
      emit(PersonalExpensesLoading());
      final result = await repository.getTransactions(userId: event.userId);
      result.fold(
        (failure) => emit(PersonalExpensesError(failure.message)),
        (transactions) => emit(PersonalExpensesLoaded(transactions)),
      );
    });

    on<AddPersonalExpenseEvent>((event, emit) async {
      emit(PersonalExpensesLoading()); // Hoặc show loading dialog
      final result = await repository.addTransaction(event.transaction);

      result.fold((failure) => emit(PersonalExpensesError(failure.message)), (
        _,
      ) {
        emit(
          const PersonalExpensesOperationSuccess("Thêm chi tiêu thành công"),
        );
        add(LoadPersonalExpensesEvent(event.transaction.userId));
      });
    });
  }
}
