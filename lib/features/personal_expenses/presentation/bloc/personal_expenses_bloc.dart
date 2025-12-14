import 'package:bill_chillin/features/personal_expenses/domain/entities/transaction_entity.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/personal_expenses_event.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/personal_expenses_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/personal_expenses_repository.dart';

class PersonalExpensesBloc
    extends Bloc<PersonalExpensesEvent, PersonalExpensesState> {
  final PersonalExpensesRepository repository;
  List<TransactionEntity> _allTransactions = [];

  PersonalExpensesBloc({required this.repository})
    : super(PersonalExpensesInitial()) {
    on<LoadPersonalExpensesEvent>(_onLoad);
    on<ChangeMonthEvent>(_onChangeMonth);
    on<ChangeSortCriteriaEvent>(_onChangeSort);
    on<DeleteTransactionEvent>(_onDelete);
    on<DeleteMultipleTransactionsEvent>(_onDeleteMultiple);
    on<AddPersonalExpenseEvent>(_onAdd);
    on<UpdateTransactionEvent>(_onUpdate);
    on<SearchTransactionEvent>(_onSearch);
  }

  Future<void> _onLoad(
    LoadPersonalExpensesEvent event,
    Emitter<PersonalExpensesState> emit,
  ) async {
    emit(PersonalExpensesLoading());
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);

    final result = await repository.getTransactions(
      userId: event.userId,
      fromDate: startOfYear,
      toDate: endOfYear,
    );

    result.fold((failure) => emit(PersonalExpensesError(failure.message)), (
      transactions,
    ) {
      _allTransactions = transactions;
      final currentMonth = DateTime(now.year, now.month);
      final filtered = _applyFilterAndSort(
        _allTransactions,
        currentMonth,
        SortCriteria.dateDesc,
        '',
      );
      emit(
        PersonalExpensesLoaded(
          filtered,
          currentMonth: currentMonth,
          sortCriteria: SortCriteria.dateDesc,
        ),
      );
    });
  }

  void _onChangeMonth(
    ChangeMonthEvent event,
    Emitter<PersonalExpensesState> emit,
  ) {
    if (state is PersonalExpensesLoaded) {
      final currentState = state as PersonalExpensesLoaded;
      final filtered = _applyFilterAndSort(
        _allTransactions,
        event.month,
        currentState.sortCriteria,
        currentState.searchQuery,
      );
      emit(
        PersonalExpensesLoaded(
          filtered,
          currentMonth: event.month,
          sortCriteria: currentState.sortCriteria,
        ),
      );
    }
  }

  void _onChangeSort(
    ChangeSortCriteriaEvent event,
    Emitter<PersonalExpensesState> emit,
  ) {
    if (state is PersonalExpensesLoaded) {
      final currentState = state as PersonalExpensesLoaded;
      final filtered = _applyFilterAndSort(
        _allTransactions,
        currentState.currentMonth,
        event.criteria,
        currentState.searchQuery,
      );
      emit(
        PersonalExpensesLoaded(
          filtered,
          currentMonth: currentState.currentMonth,
          sortCriteria: event.criteria,
        ),
      );
    }
  }

  Future<void> _onAdd(
    AddPersonalExpenseEvent event,
    Emitter<PersonalExpensesState> emit,
  ) async {

    final result = await repository.addTransaction(event.transaction);

    result.fold((failure) => emit(PersonalExpensesError(failure.message)), (_) {
      emit(
        const PersonalExpensesOperationSuccess(
          "Transaction added successfully",
        ),
      );
      add(LoadPersonalExpensesEvent(event.transaction.userId));
    });
  }

  Future<void> _onDelete(
    DeleteTransactionEvent event,
    Emitter<PersonalExpensesState> emit,
  ) async {
    final result = await repository.deleteTransaction(
      event.transactionId,
      event.userId,
    );
    result.fold((failure) => emit(PersonalExpensesError(failure.message)), (_) {
      emit(const PersonalExpensesOperationSuccess("Transaction deleted"));
      add(LoadPersonalExpensesEvent(event.userId));
    });
  }

  Future<void> _onUpdate(
    UpdateTransactionEvent event,
    Emitter<PersonalExpensesState> emit,
  ) async {
    final result = await repository.updateTransaction(event.transaction);

    result.fold((failure) => emit(PersonalExpensesError(failure.message)), (_) {
      emit(const PersonalExpensesOperationSuccess("Transaction updated"));
      add(LoadPersonalExpensesEvent(event.transaction.userId));
    });
  }

  void _onSearch(
    SearchTransactionEvent event,
    Emitter<PersonalExpensesState> emit,
  ) {
    if (state is PersonalExpensesLoaded) {
      final currentState = state as PersonalExpensesLoaded;
      final filtered = _applyFilterAndSort(
        _allTransactions,
        currentState.currentMonth,
        currentState.sortCriteria,
        event.query,
      );
      emit(
        PersonalExpensesLoaded(
          filtered,
          currentMonth: currentState.currentMonth,
          sortCriteria: currentState.sortCriteria,
          searchQuery: event.query,
        ),
      );
    }
  }

  Future<void> _onDeleteMultiple(
    DeleteMultipleTransactionsEvent event,
    Emitter<PersonalExpensesState> emit,
  ) async {
    for (final id in event.transactionIds) {
      await repository.deleteTransaction(id, event.userId);
    }
    emit(
      const PersonalExpensesOperationSuccess("Deleted selected transactions"),
    );
    add(LoadPersonalExpensesEvent(event.userId));
  }

  List<TransactionEntity> _applyFilterAndSort(
    List<TransactionEntity> all,
    DateTime month,
    SortCriteria sortCriteria,
    String? searchQuery,
  ) {
    var filtered = all.where((t) {
      return t.date.year == month.year && t.date.month == month.month;
    }).toList();

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        final matchesNote = t.note?.toLowerCase().contains(query) ?? false;
        final matchesCategory = t.categoryName.toLowerCase().contains(query);
        final matchesAmount = t.amount.toString().contains(query);
        return matchesNote || matchesCategory || matchesAmount;
      }).toList();
    }

    filtered.sort((a, b) {
      switch (sortCriteria) {
        case SortCriteria.dateDesc:
          return b.date.compareTo(a.date);
        case SortCriteria.dateAsc:
          return a.date.compareTo(b.date);
        case SortCriteria.category:
          return a.categoryName.compareTo(b.categoryName);
      }
    });

    return filtered;
  }
}
