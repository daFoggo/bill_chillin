import 'package:bill_chillin/features/scan/domain/entities/scanned_transaction.dart';

class ScannedTransactionModel extends ScannedTransaction {
  const ScannedTransactionModel({
    required super.description,
    required super.amount,
    required super.date,
    super.category,
  });

  factory ScannedTransactionModel.fromJson(Map<String, dynamic> json) {
    final desc = json['description']?.toString() ?? 'Item';
    final category = json['category']?.toString() ?? '';
    double amount = 0.0;
    final amountRaw = json['amount'];
    if (amountRaw is num) {
      amount = amountRaw.toDouble();
    } else if (amountRaw is String) {
      amount = double.parse(amountRaw);
    }
    DateTime date;
    final dateStr = json['date']?.toString();
    try {
      date = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
    } catch (_) {
      date = DateTime.now();
    }

    return ScannedTransactionModel(
      description: desc,
      amount: amount,
      date: date,
      category: category,
    );
  }
}
