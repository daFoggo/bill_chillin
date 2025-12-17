import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class PersonalExpensesRemoteDataSource {
  Future<void> addTransaction(TransactionEntity transaction);
  Future<List<TransactionModel>> getTransactions(String userId);
  Future<void> updateTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(String transactionId, String userId);
}

class PersonalExpensesRemoteDataSourceImpl
    implements PersonalExpensesRemoteDataSource {
  final FirebaseFirestore firestore;

  PersonalExpensesRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> addTransaction(TransactionEntity transaction) async {
    final collection = firestore
        .collection('users')
        .doc(transaction.userId)
        .collection('transactions');

    // Generate Firestore ID if not provided (e.g. for scanned transactions)
    final docRef = transaction.id.isNotEmpty
        ? collection.doc(transaction.id)
        : collection.doc();

    final transactionModel = TransactionModel(
      id: docRef.id,
      userId: transaction.userId,
      amount: transaction.amount,
      currency: transaction.currency,
      type: transaction.type,
      date: transaction.date,
      categoryId: transaction.categoryId,
      categoryName: transaction.categoryName,
      categoryIcon: transaction.categoryIcon,
      note: transaction.note,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
      status: transaction.status,
      groupId: transaction.groupId,
      groupName: transaction.groupName,
      payerId: transaction.payerId,
      participants: transaction.participants,
      splitDetails: transaction.splitDetails,
      imageUrl: transaction.imageUrl,
      searchKeywords: transaction.searchKeywords,
    );

    await docRef.set(transactionModel.toDocument());
  }

  @override
  Future<List<TransactionModel>> getTransactions(String userId) async {
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) async {
    final transactionModel = TransactionModel(
      id: transaction.id,
      userId: transaction.userId,
      amount: transaction.amount,
      currency: transaction.currency,
      type: transaction.type,
      date: transaction.date,
      categoryId: transaction.categoryId,
      categoryName: transaction.categoryName,
      categoryIcon: transaction.categoryIcon,
      note: transaction.note,
      createdAt: transaction.createdAt,
      updatedAt: DateTime.now(),
      status: transaction.status,
    );

    await firestore
        .collection('users')
        .doc(transaction.userId)
        .collection('transactions')
        .doc(transaction.id)
        .update(transactionModel.toDocument());
  }

  @override
  Future<void> deleteTransaction(String transactionId, String userId) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }
}
