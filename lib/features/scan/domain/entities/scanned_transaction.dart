import 'package:equatable/equatable.dart';

class ScannedTransaction extends Equatable {
  final String description; // Free text describing the line item
  final String category; // High-level category (e.g. "Food", "Transport")
  final double amount;
  final DateTime date;

  const ScannedTransaction({
    required this.description,
    required this.amount,
    required this.date,
    this.category = '',
  });

  @override
  List<Object?> get props => [description, category, amount, date];
}






