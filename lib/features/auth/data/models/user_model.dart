import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.avatarUrl,
  });

  // Firestore -> Dart object
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? data['displayName'],
      avatarUrl: data['avatarUrl'] ?? data['photoUrl'] ?? data['photoURL'],
    );
  }

  // Dart object -> Json cho Firestore
  Map<String, dynamic> toDocument() {
    return {'email': email, 'name': name, 'avatarUrl': avatarUrl};
  }
}
