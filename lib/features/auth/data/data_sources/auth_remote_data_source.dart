import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmailPassword(String email, String password);
  Future<UserModel> signUpWithEmailPassword(String email, String password);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> loginWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _getUserData(result.user!.uid);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = UserModel(
        id: result.user!.uid,
        email: email,
        name: 'New User',
      );

      await firestore
          .collection('users')
          .doc(newUser.id)
          .set(newUser.toDocument());

      return newUser;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      return await _getUserData(user.uid);
    }
    return null;
  }

  Future<UserModel> _getUserData(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    } else {
      throw ServerException();
    }
  }
}
