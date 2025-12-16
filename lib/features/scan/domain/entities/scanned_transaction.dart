import 'package:equatable/equatable.dart';

class ScannedTransaction extends Equatable {
  final String description;
  final double amount;
  final DateTime date;

  const ScannedTransaction({
    required this.description,
    required this.amount,
    required this.date,
  });

  @override
  List<Object?> get props => [description, amount, date];
}



