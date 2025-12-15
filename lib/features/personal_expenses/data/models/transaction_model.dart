import 'package:bill_chillin/core/util/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.amount,
    required super.currency,
    required super.type,
    required super.date,
    required super.categoryId,
    required super.categoryName,
    required super.categoryIcon,
    super.note,
    super.searchKeywords,
    super.status,
    super.imageUrl,
    required super.createdAt,
    super.updatedAt,
    super.groupId,
    super.groupName,
    super.payerId,
    super.participants,
    super.splitDetails,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] ?? 'VND',
      type: data['type'] ?? 'expense',

      date: (data['date'] as Timestamp).toDate(),

      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      categoryIcon: data['categoryIcon'] ?? '',
      note: data['note'],

      searchKeywords: List<String>.from(data['searchKeywords'] ?? []),
      status: data['status'] ?? 'confirmed',
      imageUrl: data['imageUrl'],

      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,

      groupId: data['groupId'],
      payerId: data['payerId'],
      participants: data['participants'] != null
          ? List<String>.from(data['participants'])
          : null,
      splitDetails: data['splitDetails'] != null
          ? Map<String, double>.from(
              data['splitDetails'].map(
                (k, v) => MapEntry(k, (v as num).toDouble()),
              ),
            )
          : null,
    );
  }

  Map<String, dynamic> toDocument() {
    String keywordInput = "${note ?? ''} $categoryName";
    List<String> keywords = StringUtils.generateKeywords(keywordInput);

    return {
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'type': type,
      'date': Timestamp.fromDate(date),

      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'note': note,

      'searchKeywords': keywords,
      'status': status,
      'imageUrl': imageUrl,

      'createdAt': Timestamp.fromDate(createdAt),

      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),

      'groupId': groupId,
      'payerId': payerId,
      'participants': participants,
      'splitDetails': splitDetails,
    };
  }
}
