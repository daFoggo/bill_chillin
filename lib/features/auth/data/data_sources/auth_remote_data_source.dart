import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailPassword(String email, String password);
  Future<UserModel> signUpWithEmailPassword(String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<List<UserModel>> getUsersByIds(List<String> userIds);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
  });

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user!;

      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? 'Google User',
        avatarUrl: user.photoURL,
      );

      await firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toDocument(), SetOptions(merge: true));

      return userModel;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
    } catch (_) {}
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel> signInWithEmailPassword(
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
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user != null) return await _getUserData(user.uid);
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

  @override
  Future<List<UserModel>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    final futures = userIds.map((uid) async {
      try {
        final doc = await firestore.collection('users').doc(uid).get();
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
      } catch (e) {
        throw ServerException();
      }
    });

    final results = await Future.wait(futures);
    return results.whereType<UserModel>().toList();
  }
}
