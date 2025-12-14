import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class CategoryDistribution extends Equatable {
  final String categoryName;
  final double percentage;
  final double totalAmount;

  const CategoryDistribution({
    required this.categoryName,
    required this.percentage,
    required this.totalAmount,
  });

  @override
  List<Object> get props => [categoryName, percentage, totalAmount];
}


enum DistributionType { expense, income }

class HomeLoaded extends HomeState {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final List<CategoryDistribution> expenseDistribution; // For BalanceCard and Donut Chart
  final List<CategoryDistribution> incomeDistribution;  // For Donut Chart
  final Map<int, double> monthlyExpenseTrends; // Key: Month (1-12), Value: Total Expense
  final Map<int, double> monthlyIncomeTrends;  // Key: Month (1-12), Value: Total Income

  const HomeLoaded({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    this.expenseDistribution = const [],
    this.incomeDistribution = const [],
    this.monthlyExpenseTrends = const {},
    this.monthlyIncomeTrends = const {},
  });

  // Backward compatibility
  List<CategoryDistribution> get categoryDistribution => expenseDistribution;
  Map<int, double> get monthlyTrends => monthlyExpenseTrends;

  @override
  List<Object> get props => [
        totalBalance, 
        totalIncome, 
        totalExpense, 
        expenseDistribution,
        incomeDistribution,
        monthlyExpenseTrends,
        monthlyIncomeTrends,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
