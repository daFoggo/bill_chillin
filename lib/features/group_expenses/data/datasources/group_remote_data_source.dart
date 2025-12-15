import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/group_model.dart';

abstract class GroupRemoteDataSource {
  Future<void> createGroup(GroupModel group);
  Future<List<GroupModel>> getGroups(String userId);
  Future<GroupModel> getGroupDetails(String groupId);
  Future<void> joinGroup(String groupId, String userId);
  Future<void> leaveGroup(String groupId, String userId);
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
      await firestore.collection('groups').doc(groupId).update({
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
}
