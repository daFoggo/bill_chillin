import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bill_chillin/features/personal_expenses/domain/repositories/personal_expenses_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final PersonalExpensesRepository repository;

  HomeBloc({required this.repository}) : super(HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);

    final result = await repository.getTransactions(
      userId: event.userId,
      fromDate: startOfYear,
      toDate: endOfYear,
    );

    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (transactions) {
        double balance = 0;
        double income = 0;
        double expense = 0;
        final Map<String, double> expenseApi = {};
        final Map<String, double> incomeApi = {};
        final Map<int, double> monthlyExpenseTrendApi = {};
        final Map<int, double> monthlyIncomeTrendApi = {};

        for (final t in transactions) {
          if (t.type == 'income') {
            income += t.amount;
            balance += t.amount;
            incomeApi.update(
              t.categoryName,
              (value) => value + t.amount,
              ifAbsent: () => t.amount,
            );
            // Monthly Trend (Income)
             monthlyIncomeTrendApi.update(
              t.date.month,
              (value) => value + t.amount,
              ifAbsent: () => t.amount,
            );
          } else {
            expense += t.amount;
            balance -= t.amount;
            expenseApi.update(
              t.categoryName,
              (value) => value + t.amount,
              ifAbsent: () => t.amount,
            );
            
            // Monthly Trend (Expense)
            monthlyExpenseTrendApi.update(
              t.date.month,
              (value) => value + t.amount,
              ifAbsent: () => t.amount,
            );
          }
        }

        final expenseDist = _calculateDistribution(expenseApi, expense);
        final incomeDist = _calculateDistribution(incomeApi, income);

        emit(HomeLoaded(
          totalBalance: balance,
          totalIncome: income,
          totalExpense: expense,
          expenseDistribution: expenseDist,
          incomeDistribution: incomeDist,
          monthlyExpenseTrends: monthlyExpenseTrendApi,
          monthlyIncomeTrends: monthlyIncomeTrendApi,
        ));
      },
    );
  }

  List<CategoryDistribution> _calculateDistribution(
    Map<String, double> data,
    double total,
  ) {
    if (total <= 0) return [];
    
    final List<CategoryDistribution> distribution = [];
    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sorted.length <= 4) {
      for (final entry in sorted) {
        distribution.add(CategoryDistribution(
          categoryName: entry.key,
          totalAmount: entry.value,
          percentage: entry.value / total,
        ));
      }
    } else {
      for (int i = 0; i < 3; i++) {
        final entry = sorted[i];
        distribution.add(CategoryDistribution(
          categoryName: entry.key,
          totalAmount: entry.value,
          percentage: entry.value / total,
        ));
      }
      double other = 0;
      for (int i = 3; i < sorted.length; i++) {
        other += sorted[i].value;
      }
      distribution.add(CategoryDistribution(
        categoryName: 'Other',
        totalAmount: other,
        percentage: other / total,
      ));
    }
    return distribution;
  }

}
