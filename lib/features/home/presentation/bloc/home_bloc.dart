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

    final result = await repository.getTransactions(userId: event.userId);

    result.fold((failure) => emit(HomeError(failure.message)), (
      allTransactions,
    ) {
      final now = DateTime.now();
      final startOfYear = DateTime(now.year, 1, 1);
      final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);
      final currentWeekday = now.weekday;
      final startOfWeek = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: currentWeekday - 1));
      final endOfWeek = DateTime(
        now.year,
        now.month,
        now.day,
        23,
        59,
        59,
      ).add(Duration(days: 7 - currentWeekday));

      double totalBalance = 0;
      // Weekly Stats
      double weeklyIncome = 0;
      double weeklyExpense = 0;
      final Map<String, double> weeklyExpenseMap = {};
      final Map<String, double> weeklyIncomeMap = {};

      // Yearly Trends
      final Map<int, double> monthlyExpenseTrendMap = {};
      final Map<int, double> monthlyIncomeTrendMap = {};

      for (final t in allTransactions) {
        // 1. Total Balance (All Time)
        if (t.type == 'income') {
          totalBalance += t.amount;
        } else {
          totalBalance -= t.amount;
        }

        // 2. Yearly Trends (Current Year)
        if (t.date.isAfter(startOfYear.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(endOfYear.add(const Duration(seconds: 1)))) {
          if (t.type == 'income') {
            monthlyIncomeTrendMap.update(
              t.date.month,
              (value) => value + t.amount,
              ifAbsent: () => t.amount,
            );
          } else {
            monthlyExpenseTrendMap.update(
              t.date.month,
              (value) => value + t.amount,
              ifAbsent: () => t.amount,
            );
          }
        }

        // 3. Weekly Stats (Current Week)
        if (t.date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(endOfWeek.add(const Duration(seconds: 1)))) {
          if (t.type == 'income') {
            weeklyIncome += t.amount;
            weeklyIncomeMap.update(
              t.categoryName,
              (value) => value + t.amount,
              ifAbsent: () => t.amount,
            );
          } else {
            weeklyExpense += t.amount;
            weeklyExpenseMap.update(
              t.categoryName,
              (value) => value + t.amount,
              ifAbsent: () => t.amount,
            );
          }
        }
      }

      final expenseDist = _calculateDistribution(
        weeklyExpenseMap,
        weeklyExpense,
      );
      final incomeDist = _calculateDistribution(weeklyIncomeMap, weeklyIncome);

      emit(
        HomeLoaded(
          totalBalance: totalBalance,
          totalIncome: weeklyIncome,
          totalExpense: weeklyExpense,
          expenseDistribution: expenseDist,
          incomeDistribution: incomeDist,
          monthlyExpenseTrends: monthlyExpenseTrendMap,
          monthlyIncomeTrends: monthlyIncomeTrendMap,
        ),
      );
    });
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
        distribution.add(
          CategoryDistribution(
            categoryName: entry.key,
            totalAmount: entry.value,
            percentage: entry.value / total,
          ),
        );
      }
    } else {
      for (int i = 0; i < 3; i++) {
        final entry = sorted[i];
        distribution.add(
          CategoryDistribution(
            categoryName: entry.key,
            totalAmount: entry.value,
            percentage: entry.value / total,
          ),
        );
      }
      double other = 0;
      for (int i = 3; i < sorted.length; i++) {
        other += sorted[i].value;
      }
      distribution.add(
        CategoryDistribution(
          categoryName: 'Other',
          totalAmount: other,
          percentage: other / total,
        ),
      );
    }
    return distribution;
  }
}
