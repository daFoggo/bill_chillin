import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../personal_expenses/data/models/transaction_model.dart';
import '../models/group_model.dart';

abstract class GroupRemoteDataSource {
  Future<void> createGroup(GroupModel group);
  Future<List<GroupModel>> getGroups(String userId);
  Future<GroupModel> getGroupDetails(String groupId);
  Future<void> joinGroup(String groupId, String userId);
  Future<void> leaveGroup(String groupId, String userId);

  Future<void> updateGroup(GroupModel group);
  Future<void> deleteGroup(String groupId);

  Future<String> generateInviteLink(String groupId);

  Future<void> addTransaction(String groupId, TransactionModel transaction);
  Future<void> updateTransaction(String groupId, TransactionModel transaction);
  Future<void> deleteTransaction(String groupId, String transactionId);
  Future<List<TransactionModel>> getGroupTransactions(String groupId);
}

class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final FirebaseFirestore firestore;

  GroupRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> createGroup(GroupModel group) async {
    try {
      await firestore
          .collection('groups')
          .doc(group.id)
          .set(group.toDocument());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<GroupModel>> getGroups(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('groups')
          .where('members', arrayContains: userId)
          .get();
      return querySnapshot.docs
          .map((doc) => GroupModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<GroupModel> getGroupDetails(String groupId) async {
    try {
      final doc = await firestore.collection('groups').doc(groupId).get();
      if (doc.exists) {
        return GroupModel.fromFirestore(doc);
      } else {
        throw ServerException('Group not found');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> joinGroup(String groupId, String userId) async {
    try {
      final groupRef = firestore.collection('groups').doc(groupId);
      final docSnapshot = await groupRef.get();

      if (!docSnapshot.exists) {
        throw ServerException('Group not found');
      }

      await groupRef.update({
        'members': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> leaveGroup(String groupId, String userId) async {
    try {
      await firestore.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateGroup(GroupModel group) async {
    try {
      await firestore
          .collection('groups')
          .doc(group.id)
          .update(group.toDocument());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      await firestore.collection('groups').doc(groupId).delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> generateInviteLink(String groupId) async {
    return 'https://billchillin.web.app/app/join/$groupId';
  }

  @override
  Future<void> addTransaction(
    String groupId,
    TransactionModel transaction,
  ) async {
    try {
      if (transaction.id.isEmpty) {
        throw ServerException('Transaction ID cannot be empty');
      }

      await firestore
          .collection('groups')
          .doc(groupId)
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toDocument());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateTransaction(
    String groupId,
    TransactionModel transaction,
  ) async {
    try {
      await firestore
          .collection('groups')
          .doc(groupId)
          .collection('transactions')
          .doc(transaction.id)
          .update(transaction.toDocument());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteTransaction(String groupId, String transactionId) async {
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
