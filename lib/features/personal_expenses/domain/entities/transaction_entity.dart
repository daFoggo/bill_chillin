import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final double amount; // Dùng double để hỗ trợ số lẻ (USD)
  final String currency; // 'VND', 'USD', ...
  final String type; // 'expense' (chi) hoặc 'income' (thu)
  final DateTime date;

  final String categoryId;
  final String categoryName;
  final String categoryIcon;

  final String? note;

  final List<String> searchKeywords;
  final String status; // 'confirmed' (đã chốt) | 'draft' (mới scan OCR)
  final String? imageUrl; // Link ảnh hóa đơn

  // Audit Trail
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Group Expense Fields
  final String? groupId;
  final String? payerId;
  final List<String>? participants;
  final Map<String, double>? splitDetails;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.amount,
    this.currency = 'VND', // Mặc định là VND
    required this.type,
    required this.date,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    this.note,
    this.searchKeywords = const [],
    this.status = 'confirmed',
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
    this.groupId,
    this.payerId,
    this.participants,
    this.splitDetails,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    amount,
    currency,
    type,
    date,
    categoryId,
    categoryName,
    categoryIcon,
    note,
    searchKeywords,
    status,
    imageUrl,
    createdAt,
    updatedAt,
    groupId,
    payerId,
    participants,
    splitDetails,
  ];
}
