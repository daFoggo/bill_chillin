import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../personal_expenses/data/models/transaction_model.dart';

abstract class GroupExpenseRemoteDataSource {
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String transactionId, String groupId);
  Future<List<TransactionModel>> getGroupTransactions(String groupId);
}

class GroupExpenseRemoteDataSourceImpl implements GroupExpenseRemoteDataSource {
  final FirebaseFirestore firestore;

  GroupExpenseRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      if (transaction.groupId == null) {
        throw ServerException('Transaction must have a groupId');
      }
      await firestore
          .collection('groups')
          .doc(transaction.groupId)
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toDocument());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      if (transaction.groupId == null) {
        throw ServerException('Transaction must have a groupId');
      }
      await firestore
          .collection('groups')
          .doc(transaction.groupId)
          .collection('transactions')
          .doc(transaction.id)
          .update(transaction.toDocument());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId, String groupId) async {
    try {
      await firestore
          .collection('groups')
          .doc(groupId)
          .collection('transactions')
          .doc(transactionId)
          .delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TransactionModel>> getGroupTransactions(String groupId) async {
    try {
      final querySnapshot = await firestore
          .collection('groups')
          .doc(groupId)
          .collection('transactions')
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
